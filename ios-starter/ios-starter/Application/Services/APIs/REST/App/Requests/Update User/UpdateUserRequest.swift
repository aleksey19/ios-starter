//
//  UpdateUserRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

struct UpdateUserRequest: HTTPRequest {
    let method: HTTPMethod = .put
    let path: String = "/users"
    let query: [URLQueryItem]?
    let body: Encodable?
    
    init(query: [URLQueryItem]? = nil, body: Encodable? = nil) {
        self.query = query
        self.body = body
    }
}

extension HTTPClient {
    
    typealias UpdateUserCompletion = ((Result<Profile>) -> Void)    
    
    func updateUser(with params: UpdateUserRequestBody,
                completion: @escaping UpdateUserCompletion) {
        let request = UpdateUserRequest(body: params)
        
        execute(request, completion: completion)
    }
}
