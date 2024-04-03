//
//  SignInFieldType.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

enum SignInFieldType: InputFieldType {
    case email
    case passsword
    case signIn
    
    func title() -> String {
        switch self {
        case .email:
            return "Email"
        case .passsword:
            return "Password"
        case .signIn:
            return "Sign In"
        }
    }
    
    func placeholder() -> String {
        return title()
    }
    
    func keyboardType() -> UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        default:
            return .default
        }
    }
}

extension SignInFieldType {
    
    func validator() -> Validator {
        switch self {
        case .email:
            return EmailValidator()
        case .passsword:
            return PasswordValidator()
        default:
            return EmptyValidator()
        }
    }
}
