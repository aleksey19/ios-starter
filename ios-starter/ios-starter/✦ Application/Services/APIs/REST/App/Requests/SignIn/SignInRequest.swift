//
//  SignInRequest.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

extension AppRestBackend {
    
    typealias SignInCompletion = ((TokensResponse?, Error?) -> Void)
    
    struct SignInParameters: Encodable {
        let email: String
        let password: String
    }
    
    func signIn(with params: SignInParameters,
                completion: @escaping SignInCompletion) {
        let url = host(for: .users) + "/sign-in"
        
        networkingService.connect(type: .post,
                                  url: url,
                                  inBodyParameters: params.stringDictionary,
                                  completion: completion)
    }
}
