//
//  VerifyAccountRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension AppRestBackend {
    
    typealias VerifyAccountCompletion = ((EmptyResponse?, Error?) -> Void)

    struct VerifyAccountParameters: Encodable {
        let email: String
        let verificationCode: String
    }
    
    func verifyAccount(with params: VerifyAccountParameters,
                       completion: @escaping VerifyAccountCompletion) {
        let url = host(for: .users) + "/account/verify/user"

        networkingService.connect(type: .post,
                                  url: url,
                                  inBodyParameters: params.stringDictionary,
                                  completion: completion)
    }
}
