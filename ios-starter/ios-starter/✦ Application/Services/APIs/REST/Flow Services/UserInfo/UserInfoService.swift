//
//  UserInfoService.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class UserInfoService {
    
    private var restBackend: AppRestBackend
    
    // MARK: - Init
    
    init(restBackend: AppRestBackend) {
        self.restBackend = restBackend
    }
}

extension UserInfoService: UserInfoServiceable {
        
    func requestCode(email: String,
                     type: String = "set",
                     completion: @escaping (EmptyResponse?, Error?) -> Void) {
        restBackend.sendResetPasswordRequest(with: email,
                                             completion: completion)
    }
    
    func registerPushNotificationsToken(with token: String,
                                        type: String,
                                        completion: @escaping AppRestBackend.RegisterPushNotificationsTokenCompletion) {
        restBackend.registerPushNotificationsToken(with: token,
                                                   type: type,
                                                   completion: completion)
    }
}
