//
//  LoginValidators.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

class NameValidator: Validator {
    var errorDomain: String { return "nameErrorDomain" }
    var nameMinLength: Int = 2
    
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Name can't be empty"]) as Error
            return error
        } else if value.count < nameMinLength {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Name's length must be at least \(nameMinLength) symbols"]) as Error
            return error
        }
        return nil
    }
}

class EmailValidator: Validator {
    var errorDomain: String { return "emailErrorDomain" }
    
    func validate(_ value: String) -> Error? {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Email address can't be empty"]) as Error
            return error
        } else if !emailPredicate.evaluate(with: value) {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Incorrect email address"]) as Error
            return error
        }
        
        return nil
    }
}

class PhoneValidator: Validator {
    var errorDomain: String { return "phoneErrorDomain" }
    
    func validate(_ value: String) -> Error? {
        let value = value.withMask(mask: "")
        
        let regex = "^[0-9+]{0,1}+[0-9]{10,16}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Phone can't be empty"]) as Error
            return error
        } else if !predicate.evaluate(with: value) && value.count < 10 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Incorrect phone number"]) as Error
            return error
        }
        return nil
    }
}

class PasswordValidator: Validator {
    var errorDomain: String { return "passwordErrorDomain" }
    
    func validate(_ value: String) -> Error? {
        if value.count < 8 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Must be at least 8 characters long"]) as Error
            return error
        } else if value.count > 16 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Can't be longer then 16 characters"]) as Error
            return error
        }
        return nil
    }
}

class ConfirmPasswordValidator: CompareValuesValidator {
    var errorDomain: String { return "passwordErrorDomain" }
    
    func validate(_ value: String, comparedValue: String) -> Error? {
        if value != comparedValue {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Both passwords must match"]) as Error
            return error
        } else if comparedValue.count < 8 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Must be at least 8 characters long"]) as Error
            return error
        } else if comparedValue.count > 16 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Can't be longer then 16 symbols"]) as Error
            return error
        }
        return nil
    }
    
    func validate(_ value: String) -> Error? {
        if value.count < 6 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Password can't be shorter then 6 symbols"]) as Error
            return error
        } else if value.count > 16 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Password can't be longer then 16 symbols"]) as Error
            return error
        }
        return nil
    }
}

class VerificationCodeValidator: Validator {
    var errorDomain: String { return "verificationCodeErrorDomain" }
    
    func validate(_ value: String) -> Error? {
        if value.count < 6 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Verification code must contain 6 numbers"]) as Error
            return error
        }
        return nil
    }
}

class EnergyBillValidator: Validator {
    var errorDomain: String { return "energyBillErrorDomain" }
    
    func validate(_ value: String) -> Error? {
        if value.count <= 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Energy bill can't be empty"]) as Error
            return error
        } else if value == "0" {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Energy bill can't be equal to zero"]) as Error
            return error
        }
        return nil
    }
}

enum EmailError: Error {
    case empty
    case wrong
}

extension EmailError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .empty:
            return "Empty email"
        case .wrong:
            return "Wrong email"
        }
    }
}

enum PasswordError: Error {
    case equalPasswords
    case notEqualPasswords
    case empty
}

extension PasswordError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .empty:
            return "Empty password"
        case .equalPasswords:
            return "Passwords should't be equal"
        case .notEqualPasswords:
            return "Confirmed password should be equal to password"
        }
    }
}
