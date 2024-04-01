//
//  SignUpFieldViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

class SignUpFieldViewModel: InputFieldViewModel {
    
    private(set) var type: SignUpFieldType
    
    init(name: String,
         value: String? = nil,
         placeholder: String? = nil,
         keyboardType: UIKeyboardType = .default,
         validator: Validator,
         type: SignUpFieldType,
         isSecureTextEntry: Bool = false,
         isPhoneNumberEntry: Bool = false,
         autocapitalizationType: UITextAutocapitalizationType = .none,
         isInputAvailable: Bool = true,
         inputMask: String? = nil) {
        
        self.type = type
        
        super.init(name: name,
                   value: value,
                   placeholder: placeholder,
                   keyboardType: keyboardType,
                   validator: validator,
                   isSecureTextEntry: isSecureTextEntry,
                   isPhoneNumberEntry: isPhoneNumberEntry,
                   autocapitalizationType: autocapitalizationType,
                   isInputAvailable: isInputAvailable,
                   inputMask: inputMask)
    }
}
