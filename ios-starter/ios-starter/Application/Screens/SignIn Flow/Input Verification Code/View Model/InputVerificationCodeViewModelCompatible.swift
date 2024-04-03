//
//  InputVerificationCodeViewModelCompatible.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift

protocol InputVerificationCodeViewModelCompatible {
    
    var verificationCodeViewModel: VerificationCodeViewModel { get }
        
    // Input    
    var resendCodeTrigger: PublishSubject<Void> { get }
    
    // Output
    var codeValidationError: Observable<Error?> { get }
    var isValidCode: Observable<Bool> { get }
}
