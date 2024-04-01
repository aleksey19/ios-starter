//
//  SignUpServiceable.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

protocol SignUpServiceable {
    func signUp(with parameters: AppRestBackend.SignUpParameters,
                completion: @escaping (TokensResponse?, Error?) -> Void)
    
    func verifyAccount(with email: String,
                       code: String,
                       completion: @escaping (EmptyResponse?, Error?) -> Void)
}
