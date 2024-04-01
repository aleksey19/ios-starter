//
//  RegisterPushNotificationsToken.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension AppRestBackend {
    
    typealias RegisterPushNotificationsTokenCompletion = ((RegisterPushNotificationsTokenResponse?, Error?) -> Void)
    
    struct RegisterPushNotificationsTokenParameters: Encodable {
        let token: String
        let type: String
    }
    
    func registerPushNotificationsToken(with token: String,
                                        type: String,
                                        completion: @escaping RegisterPushNotificationsTokenCompletion) {
        let url = host(for: .notifications) + "/fcm/token"
        let params = RegisterPushNotificationsTokenParameters(token: token,
                                                              type: type)
        
        networkingService.connect(type: .post,
                                  url: url,
                                  inBodyParameters: params.dictionary,
                                  completion: completion)
    }
}
