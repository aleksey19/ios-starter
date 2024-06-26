//
//  UserInfoServiceable.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

protocol UserInfoServiceable {
    func requestCode(email: String,
                     type: String,
                     completion: @escaping (Result<EmptyResponse>) -> Void)
    
    func registerPushNotificationsToken(with token: String,
                                        type: String,
                                        completion: @escaping RegisterPushNotificationsTokenCompletion)
}
