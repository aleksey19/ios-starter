//
//  HTTPClient.swift
//  Image Genarator
//
//  Created by Aleksey Bidnyk on 25.03.2024.
//

import Foundation

protocol HTTPClient: AnyObject {
    var scheme: String { get }
    var host: String { get }
    var apiVersion: String? { get }
    var port: Int? { get }
    var accessToken: String? { get }
    var refreshToken: String? { get }
    
    var session: URLSession { get }
    var task: URLSessionDataTask? { get set }
    var request: URLRequest? { get set }
    
    var presetRetryCount: Int { get }
    var presetRefreshTokenRetryCount: Int { get }
    var presetTimeout: Double { get }
    var retryCounter: Int { get }
    var refreshTokenRetryCounter: Int { get }
    
    func makeURLRequest(_ request: HTTPRequest) throws -> URLRequest?
    func composeRequestHeaders() -> [String: String]
    func run<T: Decodable>(_ request: URLRequest, completion: ((Result<T>) -> Void)?)
    
    func logRequest(_ request: URLRequest)
    func logResponse(_ response: URLResponse?, data: Data?, error: Error?)
    
    func resetRetryConuter()
    func decrementRetryConuter()
    
    func resetRefreshTokenConuter()
    func decrementRefreshTokenConuter()
    
    
    typealias NotAuthorizedHandler = (() -> Void)
    typealias ServerErrorHandler = ((String) -> Void)
    typealias SetAuthorizationTokenHandler = ((_ token: String, _ refreshToken: String) -> Void)
    typealias RefreshAuthorizationTokenHandler = (() -> Void)
    
    var notAuthorizedHandler: NotAuthorizedHandler? { get }
    var serverErrorHandler: ServerErrorHandler? { get }
    var setAuthorizationTokenHandler: SetAuthorizationTokenHandler? { get }
    var refreshAuthorizationTokenHandler: RefreshAuthorizationTokenHandler? { get }
}

// MARK: - Composing URLRequest

extension HTTPClient {
    
    func composeRequestHeaders() -> [String: String] {
        var headers = request?.allHTTPHeaderFields ?? [:]
        
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json"
        
        if let token = accessToken {
            headers["Authorization"] = "Bearer " + token
        }
        
        return headers
    }
    
    func makeURLRequest(_ request: HTTPRequest) throws -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        let path = apiVersion != nil ? apiVersion!.appending(request.path) : request.path
        urlComponents.path = "/".appending(path)
        
        if let query = request.query {
            urlComponents.queryItems = query
        }
        
        if let url = urlComponents.url {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.method.rawValue.uppercased()
            urlRequest.allHTTPHeaderFields = composeRequestHeaders()
            
            if let body = request.body {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            }
            
            return urlRequest
        } else {
            throw wrongUrlError
        }
    }
    
    private var wrongUrlError: Error {
        AppError.develop("Error while composing request URL")
    }
    
    func resetRetryConuter() { }
    func decrementRetryConuter() { }
    
    func resetRefreshTokenConuter() { }
    func decrementRefreshTokenConuter() { }
}

// MARK: - Methods

extension HTTPClient {
    
    func execute<T: Decodable>(_ request: HTTPRequest, completion: ((Result<T>) -> Void)?) {
        resetRetryConuter()
        
        do {
            self.request = try makeURLRequest(request)
            runWithRetry(self.request!) { (result: Result<T>) in
                completion?(result)
            }
        } catch let error {
            AppLogger.shared.log(error: error)
            completion?(.failure(error))
        }
    }
    
    func runWithRetry<T: Decodable>(_ request: URLRequest, completion: ((Result<T>) -> Void)?) {
        run(request) { [weak self] (result: Result<T>) in
            switch result {
            case .success:
                completion!(result)
            case.failure:
                if self?.retryCounter ?? 0 > 0 {
                    AppLogger.shared.log(info: "Retrying request \(request.url?.pathExtension ?? "")")
                    
                    self?.runWithRetry(request){ (result: Result<T>) in
                        completion!(result)
                    }
                } else {
                    completion!(result)
                }
                
                self?.decrementRetryConuter()
            }
        }
    }
    
    func run<T: Decodable>(_ request: URLRequest, completion: ((Result<T>) -> Void)?) {
        logRequest(request)
        
        self.task = session.dataTask(with: request) { [weak self] (responseData, response, responseError) in
            self?.logResponse(response, data: responseData, error: responseError)
            
            // Print raw json
            if let jdata = responseData,
               let utf8Representation = String(data: jdata, encoding: .utf8) {
                debugPrint("response: \(utf8Representation)")
            } else if responseData == nil {
                debugPrint("no readable data received in run")
            }
            
            if let responseError = responseError {
                AppLogger.shared.log(error: responseError)
                
                if response == nil,
                   responseError.localizedDescription.localizedStandardContains("The request timed out.") == false {
                    self?.serverErrorHandler?(responseError.localizedDescription)
                }
                
                completion?(.failure(responseError))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let error = AppError.server("Unknown response type")
                completion?(.failure(error))
                return
            }
            
            // Authorize to view this resource
            if statusCode == 401 {
                if self?.accessToken != nil {
//                    self?.refreshToken(completion: completion)
                } else {
//                    self?.notAuthorizedHandler?()
                    completion?(.failure(AppError.server("401 error")))
                }
                return
            }
            
            // Update application to view this resource
            if statusCode == 426 {
                let error = NSError(domain: "HTTPResponseError",
                                    code: statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: "Application version outdated. Please update the application!"])
                self?.serverErrorHandler?(error.localizedDescription)
                completion?(.failure(error))
                
                return
            }
            
            // Handle 204 code (request succeded but returned empty response)
            if statusCode == 204 {
                completion?(.success(true as! T))
                return
            }
            
            // Handle success status but empty response data
            guard let data = responseData,
                  statusCode != 204 else {
                let error = AppError.server("Request succeded but response data is empty")
                
                completion?(.failure(error))
                return
            }
            
            // If execution reaches here request has finished with 200 code
            if self?.refreshTokenRetryCounter != self?.presetRefreshTokenRetryCount {
                self?.resetRefreshTokenConuter()
            }
            
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                                
                completion?(.success(object))
            } catch let error {
                AppLogger.shared.log(error: error)
                
                completion?(.failure(error))
            }
        }
        task?.resume()
    }
}

// MARK: - Refresh token

extension HTTPClient {
    
    /**
     Refreshes authorisation token.
     If refresh fails or refresh count expires then execute `notAuthorizedHandler` (redirects to sign in).
     */
    
}
