//
//  Unregister.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension AppRestBackend {
    
    typealias UnregisterPushNotificationsTokenCompletion = ((UnregisterPushNotificationsTokenResponse?, Error?) -> Void)
    
    func unregisterPushNotificationsToken(_ token: String,
                                          completion: @escaping UnregisterPushNotificationsTokenCompletion) {
        let url = host(for: .notifications) + "/devices/unregister"
        let params = ["token": token]                
        
        networkingService.connect(type: .post,
                                  url: url,
                                  inBodyParameters: params,
                                  completion: completion)
    }
}
