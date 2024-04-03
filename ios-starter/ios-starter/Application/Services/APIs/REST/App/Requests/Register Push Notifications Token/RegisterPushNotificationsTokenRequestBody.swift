//
//  RegisterPushNotificationsTokenRequestBody.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 01.04.2024.
//

import Foundation

struct RegisterPushNotificationsTokenRequestBody: Encodable {
    let token: String
    let type: String
}
