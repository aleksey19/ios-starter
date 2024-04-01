//
//  VerifyEmailToChangePasswordViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxRelay

class VerifyEmailToChangePasswordViewModel: VerifyEmailViewModel {
    
    private weak var coordinator: SignInFlowCoordinatorable?
    
    override var title: String {
        return "Reset Password"
    }
    override var message: String {
        return "We just need to verify your email address before we can edit password. "
    }
    
    // MARK: - Init
    
    init(coordinator: SignInFlowCoordinatorable,
         signUpService: SignUpServiceable,
         userService: UserInfoServiceable,
         email: String) {
        self.coordinator = coordinator
        
        super.init(coordinator: coordinator,
                   signUpService: signUpService,
                   userService: userService,
                   email: email,
                   type: "reset")
    }
    
    // MARK: - Proceed
    
    override func continueAfterSuccessfullVerification(email: String, code: String) {
//        coordinator?.showChangePassword(email: email, verificationCode: code)
    }
}
