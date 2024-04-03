//
//  Authorization.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class Authorization {
    
    // MARK: - Properties. Authorization
    private static let AppSessionTokenAccessKey: String = "app_backend_token_access_key"
    private static let AppSessionTokenTypeAccessKey: String = "app_backend_token_type_access_key"
    private static let AppSessionRefreshTokenAccessKey: String = "app_backend_refresh_token_access_key"
    
    var authorization: (type: String, token: String, refreshToken: String)? {
        get {
            guard
                let typeData = KeychainService.load(key: Self.AppSessionTokenTypeAccessKey),
                let tokenData = KeychainService.load(key: Self.AppSessionTokenAccessKey),
                let refreshTokenData = KeychainService.load(key: Self.AppSessionRefreshTokenAccessKey),
                let type = String.init(data: typeData, encoding: .utf8),
                let token = String.init(data: tokenData, encoding: .utf8),
                let refreshToken = String.init(data: refreshTokenData, encoding: .utf8) else {
                return nil
            }
            
            let authotization = (type, token, refreshToken)
            
            return authotization
        }
        set {
            clear()

            guard let authorization = newValue else {
                return
            }

            if
                let typeData = authorization.type.data(using: .utf8),
                let tokenData = authorization.token.data(using: .utf8),
                let refreshTokenData = authorization.refreshToken.data(using: .utf8) {
                KeychainService.save(key: Self.AppSessionTokenTypeAccessKey, data: typeData)
                KeychainService.save(key: Self.AppSessionTokenAccessKey, data: tokenData)
                KeychainService.save(key: Self.AppSessionRefreshTokenAccessKey, data: refreshTokenData)
            }
        }
    }
    
    init(type: String,
         token: String,
         refreshToken: String) {
        authorization = (type, token, refreshToken)
    }
    
    deinit {
        clear()
    }
    
    private func clear() {
        KeychainService.delete(key: Self.AppSessionTokenAccessKey)
        KeychainService.delete(key: Self.AppSessionTokenTypeAccessKey)
        KeychainService.delete(key: Self.AppSessionRefreshTokenAccessKey)
    }
}
