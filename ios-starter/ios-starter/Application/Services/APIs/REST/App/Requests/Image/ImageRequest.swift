//
//  ImageRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension HTTPClient {
    
    typealias ImageCompletion = (Result<Data> -> Void)
    
    struct ImageRequest: HTTPRequest {
        let method: HTTPMethod = .get
        let path: String = "/image"
        let query: [URLQueryItem]?
        let body: Encodable?
        
        init(query: [URLQueryItem]? = nil, body: Encodable? = nil) {
            self.query = query
            self.body = body
        }
    }
    
    func image(url: String,
               completion: @escaping ImageCompletion) {
        networkingService.image(url: url,
                                inPathParameters: inPathParameters,
                                completion: completion)
        let request =
        execute(<#T##request: HTTPRequest##HTTPRequest#>, completion: <#T##((Result<Decodable>) -> Void)?##((Result<Decodable>) -> Void)?##(Result<Decodable>) -> Void#>)
    }
}
