//
//  GetUser.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

struct UserRequest: HTTPRequest {
    let method: HTTPMethod = .get
    let path: String = "/users"
    let query: [URLQueryItem]?
    let body: Encodable?
    
    init(query: [URLQueryItem]? = nil, body: Encodable? = nil) {
        self.query = query
        self.body = body
    }
}

extension HTTPClient {
    
    typealias UserCompletion = ((Result<Profile>) -> Void)
    
    func user(completion: @escaping SignInCompletion) {
        let request = UserRequest()
        
        execute(request, completion: completion)
    }
}
