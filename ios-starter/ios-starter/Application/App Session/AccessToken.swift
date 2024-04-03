//
//  AccessToken.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 03.04.2024.
//

import Foundation

/// Saves and extracts session token using keychain
final class AccessToken {
    
    static var token: String? {
        get {
            guard let tokenData = KeychainService.load(key: "AppSessionTokenAccessKey"),
                  let token = String.init(data: tokenData, encoding: .utf8) else {
                return nil
            }
            return token
        }
        set {
            if let data = newValue?.data(using: .utf8) {
                KeychainService.save(key: "AppSessionTokenAccessKey", data: data)
            } else {
                KeychainService.delete(key: "AppSessionTokenAccessKey")
            }
        }
    }
    
    static var refreshToken: String? {
        get {
            guard let tokenData = KeychainService.load(key: "AppSessionRefreshTokenAccessKey"),
                  let token = String.init(data: tokenData, encoding: .utf8) else {
                return nil
            }
            return token
        }
        set {
            if let data = newValue?.data(using: .utf8) {
                KeychainService.save(key: "AppSessionRefreshTokenAccessKey", data: data)
            } else {
                KeychainService.delete(key: "AppSessionRefreshTokenAccessKey")
            }
        }
    }
}
