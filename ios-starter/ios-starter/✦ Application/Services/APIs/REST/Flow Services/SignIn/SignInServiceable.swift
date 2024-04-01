//
//  SignInServiceable.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

protocol SignInServiceable {
    func signIn(with email: String,
                password: String,
                completion: @escaping ((TokensResponse?, Error?) -> Void))
    
    func sendResetPasswordRequest(with email: String,
                                  completion: @escaping ((EmptyResponse?, Error?) -> Void))
}
