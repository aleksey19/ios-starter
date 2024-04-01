//
//  CommonValidator.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

class CommonValidator: Validator {
    var errorDomain: String { return "commonErrorDomain" }
    var minLength: Int = 2
    
    func validate(_ value: String) -> Error? {
        if value.count == 0 {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Value can't be empty"]) as Error
            return error
        }
        return nil
    }
}
