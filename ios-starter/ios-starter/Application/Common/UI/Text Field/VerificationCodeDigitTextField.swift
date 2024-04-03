//
//  TextField.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

class VerificationCodeDigitTextField: UITextField {
    
    var deleteKeyPressedIfEmptyText: ((_ textField: UITextField) -> Void)?
    
    override func deleteBackward() {
        if text?.count == 0 {
            deleteKeyPressedIfEmptyText?(self)
        } else {
            super.deleteBackward()
        }
    }
}
