//
//  UnregisterPushNotificationsTokenRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

struct UnregisterPushNotificationsTokenRequest: HTTPRequest {
    let method: HTTPMethod = .post
    let path: String = "/fcm/token/unregister"
    let query: [URLQueryItem]?
    let body: Encodable?
    
    init(query: [URLQueryItem]? = nil, body: Encodable? = nil) {
        self.query = query
        self.body = body
    }
}

extension HTTPClient {
    
    typealias UnregisterPushNotificationsTokenCompletion = ((Result<UnregisterPushNotificationsTokenResponse>) -> Void)
    
    func unregisterPushNotificationsToken(_ token: String,
                                          completion: @escaping UnregisterPushNotificationsTokenCompletion) {
        let body = UnregisterPushNotificationsTokenRequestBody(token: token)
        let request = UnregisterPushNotificationsTokenRequest(body: body)
        
        execute(request, completion: completion)
    }
}
