//
//  SignUpService.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class SignUpService {
    
    private var restBackend: HTTPClient
    
    // MARK: - Init
    
    init(restBackend: HTTPClient) {
        self.restBackend = restBackend
    }
}

extension SignUpService: SignUpServiceable {
    
    func signUp(with parameters: SignUpRequestBody,
                completion: @escaping SignUpCompletion) {
        restBackend.signUp(with: parameters,
                           completion: completion)
    }
    
    func verifyAccount(with email: String,
                       code: String,
                       completion: @escaping VerifyAccountCompletion) {
        let params = VerifyAccountRequestBody(email: email, verificationCode: code)
        
        restBackend.verifyAccount(with: params,
                                  completion: completion)
    }
}
