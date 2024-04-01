//
//  SignUpService.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class SignUpService {
    
    private var restBackend: AppRestBackend
    
    // MARK: - Init
    
    init(restBackend: AppRestBackend) {
        self.restBackend = restBackend
    }
}

extension SignUpService: SignUpServiceable {
    
    func signUp(with parameters: AppRestBackend.SignUpParameters,
                completion: @escaping AppRestBackend.SignUpCompletion) {
        restBackend.signUp(with: parameters,
                           completion: completion)
    }
    
    func verifyAccount(with email: String,
                       code: String,
                       completion: @escaping (EmptyResponse?, Error?) -> Void) {
        let params = AppRestBackend.VerifyAccountParameters(email: email, verificationCode: code)
        
        restBackend.verifyAccount(with: params,
                                  completion: completion)
    }
}
