//
//  ResetPasswordRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

struct ResetPasswordRequest: HTTPRequest {
    let method: HTTPMethod = .post
    let path: String = "/users/reset-password"
    let query: [URLQueryItem]?
    let body: Encodable?
    
    init(query: [URLQueryItem]? = nil, body: Encodable? = nil) {
        self.query = query
        self.body = body
    }
}

typealias ResetPasswordCompletion = ((Result<EmptyResponse>) -> Void)

extension HTTPClient {
    
    func sendResetPasswordRequest(with email: String,
                                  completion: @escaping ResetPasswordCompletion) {
        let body = ResetPasswordRequestBody(email: email)
        let request = ResetPasswordRequest(body: body)
        
        execute(request, completion: completion)
    }
}
