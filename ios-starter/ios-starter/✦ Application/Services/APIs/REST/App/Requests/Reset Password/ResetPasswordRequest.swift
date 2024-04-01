//
//  ResetPasswordRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension AppRestBackend {
    
    typealias ResetPasswordCompletion = ((EmptyResponse?, Error?) -> Void)
    
    struct ResetPasswordParameters: Encodable {
        let email: String
    }
    
    func sendResetPasswordRequest(with email: String,
                                  completion: @escaping ResetPasswordCompletion) {
        let url = host(for: .users) + "/reset-password"
        let params = ResetPasswordParameters(email: email)
        
        networkingService.connect(type: .post,
                                  url: url,
                                  inBodyParameters: params.stringDictionary,
                                  completion: completion)
    }
}
