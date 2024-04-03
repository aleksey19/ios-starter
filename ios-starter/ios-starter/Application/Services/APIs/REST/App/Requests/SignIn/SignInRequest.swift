//
//  SignInRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

struct SignInRequest: HTTPRequest {
    let method: HTTPMethod = .post
    let path: String = "/sign-in"
    let query: [URLQueryItem]?
    let body: Encodable?
    
    init(query: [URLQueryItem]? = nil, body: Encodable? = nil) {
        self.query = query
        self.body = body
    }
}

typealias SignInCompletion = ((Result<TokensResponse>) -> Void)

extension HTTPClient {
    
    func signIn(with params: SignInRequestBody,
                completion: @escaping SignInCompletion) {
        let request = SignInRequest(body: params)
        
        execute(request, completion: completion)
    }
}
