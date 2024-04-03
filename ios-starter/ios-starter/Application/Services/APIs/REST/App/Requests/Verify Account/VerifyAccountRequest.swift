//
//  VerifyAccountRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

struct VerifyRequest: HTTPRequest {
    let method: HTTPMethod = .post
    let path: String = "/account/verify/user"
    let query: [URLQueryItem]?
    let body: Encodable?
    
    init(query: [URLQueryItem]? = nil, body: Encodable? = nil) {
        self.query = query
        self.body = body
    }
}

typealias VerifyAccountCompletion = ((Result<EmptyResponse>) -> Void)

extension HTTPClient {
    
    func verifyAccount(with params: VerifyAccountRequestBody,
                       completion: @escaping VerifyAccountCompletion) {
        let request = VerifyRequest(body: params)
        
        execute(request, completion: completion)
    }
}
