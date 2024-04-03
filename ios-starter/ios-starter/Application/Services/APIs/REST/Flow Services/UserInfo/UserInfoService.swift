//
//  UserInfoService.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class UserInfoService {
    
    private var restBackend: HTTPClient
    
    // MARK: - Init
    
    init(restBackend: HTTPClient) {
        self.restBackend = restBackend
    }
}

extension UserInfoService: UserInfoServiceable {
        
    func requestCode(email: String,
                     type: String = "set",
                     completion: @escaping ResetPasswordCompletion) {
        restBackend.sendResetPasswordRequest(with: email,
                                             completion: completion)
    }
    
    func registerPushNotificationsToken(with token: String,
                                        type: String,
                                        completion: @escaping RegisterPushNotificationsTokenCompletion) {
        restBackend.registerPushNotificationsToken(with: token,
                                                   type: type,
                                                   completion: completion)
    }
}
