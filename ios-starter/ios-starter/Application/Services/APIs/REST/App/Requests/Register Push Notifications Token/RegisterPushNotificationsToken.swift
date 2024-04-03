//
//  RegisterPushNotificationsToken.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

struct RegisterPushNotificationsTokenRequest: HTTPRequest {
    let method: HTTPMethod = .post
    let path: String = "/fcm/token"
    let query: [URLQueryItem]?
    let body: Encodable?
    
    init(query: [URLQueryItem]? = nil, body: Encodable? = nil) {
        self.query = query
        self.body = body
    }
}

typealias RegisterPushNotificationsTokenCompletion = ((Result<RegisterPushNotificationsTokenResponse>) -> Void)

extension HTTPClient {
    
    func registerPushNotificationsToken(with token: String,
                                        type: String,
                                        completion: @escaping RegisterPushNotificationsTokenCompletion) {
        let body = RegisterPushNotificationsTokenRequestBody(token: token,
                                                              type: type)
        let request = RegisterPushNotificationsTokenRequest(body: body)
        
        execute(request, completion: completion)
    }
}
