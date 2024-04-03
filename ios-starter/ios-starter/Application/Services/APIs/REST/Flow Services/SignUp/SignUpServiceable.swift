//
//  SignUpServiceable.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

protocol SignUpServiceable {
    func signUp(with parameters: SignUpRequestBody,
                completion: @escaping (Result<TokensResponse>) -> Void)
    
    func verifyAccount(with email: String,
                       code: String,
                       completion: @escaping (Result<EmptyResponse>) -> Void)
}
