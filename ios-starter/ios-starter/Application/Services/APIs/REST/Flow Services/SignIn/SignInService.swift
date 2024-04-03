//
//  SignInService.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class SignInService {
    
    private var restBackend: HTTPClient
    
    // MARK: - Init
    
    init(restBackend: HTTPClient) {
        self.restBackend = restBackend
    }
}

extension SignInService: SignInServiceable {
    
    func signIn(with email: String,
                password: String,
                completion: @escaping SignInCompletion) {
        let parameters = SignInRequestBody(email: email,
                                           password: password)
        
        restBackend.signIn(with: parameters,
                           completion: completion)
    }
    
    func sendResetPasswordRequest(with email: String,
                                  completion: @escaping ResetPasswordCompletion) {
        restBackend.sendResetPasswordRequest(with: email,
                                             completion: completion)
    }
}
