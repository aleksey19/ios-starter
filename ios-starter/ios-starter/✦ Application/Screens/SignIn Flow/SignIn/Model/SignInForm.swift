//
//  SignInForm.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

class SignInForm: InputForm<SignInFieldType, SignInFieldViewModel> {
    
    var email: String? {
        viewModels.first(where: { $0.type == .email })?.value
    }
    
    var password: String? {
        viewModels.first(where: { $0.type == .passsword })?.value
    }

    func loginObject() -> AppRestBackend.SignInParameters {
        let email: String = email ?? ""
        let password: String = password ?? ""

        return .init(email: email, password: password)
    }
}
