//
//  ResetPasswordForm.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

class ResetPasswordForm: InputForm<ResetPasswordFieldType, ResetPasswordFieldViewModel> {
    
    var email: String? {
        viewModels.first(where: { $0.type == .email })?.value
    }
}
