//
//  RESTService+App.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension RESTService {

    func image(url: String,
               inPathParameters: [String: String]? = nil,
               completion: ((Data?, Error?) -> Void)?) {
        if URL(string: url) == nil {
            completion?(nil, AppError.develop("Wrong url"))
            return
        } else {
            self.downloadImage(url: url,
                               inPathParameters: inPathParameters,
                               mimeType: .jpeg,
                               completion: { (error, data, _) in
                                completion?(data, error)
                               },
                               progress: nil)
        }
    }

//    func file(url: String,
//              inPathParameters pathParameters: [String: String]? = nil,
//              inBodyParameters bodyParameters: [String: Any]? = nil,
//              saveToCache: Bool = false,
//              saveToDisk: Bool = false) -> Observable<(url: URL?, progress: (part: Int64, total: Int64)?)> {
//        return Observable<(url: URL?, progress: (part: Int64, total: Int64)?)>.create { observer in
//            self.file(url: url,
//                      inPathParameters: pathParameters,
//                      inBodyParameters: bodyParameters,
//                      saveToCache: saveToCache,
//                      saveToDisk: saveToDisk,
//                      completion: {error, fileUrl, _ in
//                        if let error = error {
//                            observer.onError(error)
//                            AppLogger.shared.log(error: error)
//                            return
//                        }
//
//                        guard let fileUrl = fileUrl else {
//                            let error = self.generateError(description: "Request \(url) succeded but got empty data")
//                            observer.onError(error)
//                            AppLogger.shared.log(error: error)
//                            return
//                        }
//
//                        observer.onNext((url: fileUrl, progress: (1, 1)))
//                        observer.onCompleted()
//                      },
//                      progress: { part, total in
//                        if let part = part, let total = total {
//                            observer.onNext((url: nil, progress: (part, total)))
//                        }
//                      })
//
//            return Disposables.create {
//                let path = self.add(toPath: url, parameters: pathParameters)
//                self.removeTasks(containingPath: path)
//            }
//        }
//        .share()
//    }
    
    @discardableResult
    func connect<ParseType: Decodable>(type: RestType,
                                       url: String,
                                       inPathParameters pathParameters: [String: String]? = nil,
                                       inBodyParameters bodyParameters: [String: Any]? = nil,
                                       completion: @escaping ((ParseType?, Error?) -> Void)) -> URLSessionTask? {
        let task = self.connect(type: type,
                                url: url,
                                inPathParameters: pathParameters,
                                inBodyParameters: bodyParameters,
                                completion: { (error, data, _) in
                                    if let response: EmptyResponse = data?.parse(),
                                       response.success == false,
                                       let errorMessage = response.errors?.first {
                                        let error = self.generateError(description: errorMessage)
                                        AppLogger.shared.log(error: error)
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    if let error = error {
                                        AppLogger.shared.log(error: error)
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    guard let data = data else {
                                        let error = self.generateError(description: "Request \(url) succeded but got empty data")
                                        AppLogger.shared.log(error: error)
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    guard let response: ParseType = data.parse() else {
                                        let error = self.generateError(description: "Request \(url) succeded but data parsing failed")
                                        AppLogger.shared.log(error: error)
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    // Handle Response error
                                    if let responseError = self.generateError(from: data, basedOn: error) {
                                        AppLogger.shared.log(error: responseError)
                                        completion(nil, error)
                                        return
                                    }
                                    
                                    completion(response, nil)
                                })
        
        return task
    }

//    func connect<ParseType: Decodable>(url: String,
//                                       fileLocalUrl: URL,
//                                       fileParameterName: String,
//                                       inPathParameters pathParameters: [String: String]? = nil,
//                                       inBodyParameters bodyParameters: [String: String]? = nil) ->
//    Observable<(data: ParseType?, progress: (part: Int64, total: Int64)?)> {
//
//        return Observable<(data: ParseType?, progress: (part: Int64, total: Int64)?)>.create { observer in
//            self.connect(url: url,
//                         fileLocalUrl: fileLocalUrl,
//                         fileParameterName: fileParameterName,
//                         inPathParameters: pathParameters,
//                         inBodyParameters: bodyParameters,
//                         completion: { error, data, _ in
//                            if let error = error {
//                                observer.onError(error)
//                                AppLogger.shared.log(error: error)
//                                return
//                            }
//
//                            guard let data = data else {
//                                let error = self.generateError(description: "Request \(url) succeded but got empty data")
//                                observer.onError(error)
//                                AppLogger.shared.log(error: error)
//                                return
//                            }
//
//                            guard let response: ParseType = data.parse() else {
//                                let error = self.generateError(description: "Request \(url) succeded but data parsing failed")
//                                observer.onError(error)
//                                AppLogger.shared.log(error: error)
//                                return
//                            }
//
//                            observer.onNext((data: response, progress: (1, 1)))
//                            observer.onCompleted()
//            },
//                         sendProgress: { part, total in
//                            if let part = part, let total = total {
//                                observer.onNext((data: nil, progress: (part, total)))
//                            }
//            })
//
//            return Disposables.create {
//                let path = self.add(toPath: url, parameters: pathParameters)
//                self.removeTasks(containingPath: path)
//            }
//        }
//    }
}
