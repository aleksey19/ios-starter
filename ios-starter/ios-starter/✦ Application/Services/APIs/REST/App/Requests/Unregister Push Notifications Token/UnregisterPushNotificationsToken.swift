//
//  Unregister.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension HTTPClient {
    
    typealias UnregisterPushNotificationsTokenCompletion = ((Result<UnregisterPushNotificationsTokenResponse>) -> Void)
    
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
    
    func unregisterPushNotificationsToken(_ token: String,
                                          completion: @escaping UnregisterPushNotificationsTokenCompletion) {
        let params = ["token": token]
        let request = UnregisterPushNotificationsTokenRequest(body: params)
        
        execute(request, completion: completion)
    }
}
