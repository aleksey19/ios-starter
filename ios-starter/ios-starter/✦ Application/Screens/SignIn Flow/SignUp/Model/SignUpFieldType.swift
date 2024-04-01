//
//  SignUpFieldType.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

enum SignUpFieldType: InputFieldType {
    case fullName
    case address
    case address2
    case city
    case state
    case zip
    case stateAndZip
    case accountType
    case phone
    case password
    case confirmPassword
    case signUp
    
    case source
    case customSource
    
    func title() -> String {
        switch self {
        case .fullName:
            return "Full Name"
        case .address:
            return "Address 1"
        case .address2:
            return "Address 2"
        case .city:
            return "City"
        case .state:
            return "State"
        case .zip:
            return "Zip Code"
        case .stateAndZip:
            return ""
        case .accountType:
            return "Account Type"
        case .phone:
            return "Phone number"
        case .password:
            return "Password"
        case .confirmPassword:
            return "Confirm Password"
        case .signUp:
            return "Sign Up"
            
        case .source:
            return "Where are you from?"
        case .customSource:
            return "Custom"
        }
    }
    
    func placeholder() -> String {
        switch self {
        case .zip:
            return "55555"
        case .phone:
            return "(555) 555-5555"
        default:
            return title()
        }
    }
    
    func keyboardType() -> UIKeyboardType {
        switch self {
        case .phone:
            return .phonePad
        default:
            return .default
        }
    }
}

extension SignUpFieldType {
    
    func validator() -> Validator {
        switch self {
        case .fullName:
            return NameValidator()
        case .phone:
            return PhoneValidator()
        case .password:
            return PasswordValidator()
        case .confirmPassword:
            return ConfirmPasswordValidator()
//        case .code:
//            return VerificationCodeValidator()
//        case .birthDate:
//            return BirthDateValidator()
//        case .email:
//            return EmailValidator()
            
        case .address:
            return AddressValidator()
        case .address2:
            return EmptyValidator()
        case .city:
            return CityValidator()
        case .state:
            return StateValidator()
        case .zip:
            return PostalCodeValidator()
        case .accountType:
            return CommonValidator()
        default:
            return EmptyValidator()
        }
    }
}
