//
//  ResetPasswordFieldType.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

enum ResetPasswordFieldType: InputFieldType {
    case email
    case reset
    
    func title() -> String {
        switch self {
        case .email:
            return "Email"
        case .reset:
            return "Reset Password"
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

extension ResetPasswordFieldType {
    
    func validator() -> Validator {
        switch self {
        case .email:
            return EmailValidator()
        default:
            return EmptyValidator()
        }
    }
}
