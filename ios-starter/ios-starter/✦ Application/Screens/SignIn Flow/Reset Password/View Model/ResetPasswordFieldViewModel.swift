//
//  ResetPasswordFieldViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

class ResetPasswordFieldViewModel: InputFieldViewModel {
    
    private(set) var type: ResetPasswordFieldType
    
    init(name: String,
         value: String? = nil,
         placeholder: String?,
         keyboardType: UIKeyboardType = .default,
         validator: Validator,
         type: ResetPasswordFieldType,
         isSecureTextEntry: Bool = false) {
        
        self.type = type
        
        super.init(name: name,
                   value: value,
                   placeholder: placeholder,
                   keyboardType: keyboardType,
                   validator: validator,
                   isSecureTextEntry: isSecureTextEntry)
    }
}
