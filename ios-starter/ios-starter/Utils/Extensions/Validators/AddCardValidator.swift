//
//  AddCardValidator.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

class CardNumberValidator: Validator {
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

class ExpireMonthValidator: Validator {
    var errorDomain: String { return "nameErrorDomain" }
    var maxLength: Int = 2
    
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Expire month can't be empty"]) as Error
            return error
        } else if value.count > maxLength {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Incorrect Expire month"]) as Error
            return error
        }
        return nil
    }
}

class ExpireYearValidator: Validator {
    var errorDomain: String { return "nameErrorDomain" }
    var maxLength: Int = 2
    
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Expire year can't be empty"]) as Error
            return error
        } else if value.count > maxLength {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Incorrect Expire year"]) as Error
            return error
        }
        return nil
    }
}

class CardTypeValidator: Validator {
    var errorDomain: String { return "nameErrorDomain" }
        
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Card type can't be empty"]) as Error
            return error
        }
        return nil
    }
}

class AddressValidator: Validator {
    var errorDomain: String { return "nameErrorDomain" }
        
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Address can't be empty"]) as Error
            return error
        }
        return nil
    }
}

class CityValidator: Validator {
    var errorDomain: String { return "nameErrorDomain" }
        
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "City can't be empty"]) as Error
            return error
        }
        return nil
    }
}

class StateValidator: Validator {
    var errorDomain: String { return "nameErrorDomain" }
        
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "State can't be empty"]) as Error
            return error
        }
        return nil
    }
}

class PostalCodeValidator: Validator {
    var errorDomain: String { return "nameErrorDomain" }
        
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Postal code can't be empty"]) as Error
            return error
        }
        return nil
    }
}

class CountryValidator: Validator {
    var errorDomain: String { return "nameErrorDomain" }
        
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Country can't be empty"]) as Error
            return error
        }
        return nil
    }
}
