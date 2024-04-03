//
//  SignUpRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

struct SignUpRequest: HTTPRequest {
    let method: HTTPMethod = .post
    let path: String = "/users/sign-up"
    let query: [URLQueryItem]?
    let body: Encodable?
    
    init(query: [URLQueryItem]? = nil, body: Encodable? = nil) {
        self.query = query
        self.body = body
    }
}

typealias SignUpCompletion = ((Result<TokensResponse>) -> Void)

extension HTTPClient {
    
    func signUp(with params: SignUpRequestBody,
                completion: @escaping SignUpCompletion) {
        let request = SignUpRequest(body: params)
        
        execute(request, completion: completion)
    }
}
