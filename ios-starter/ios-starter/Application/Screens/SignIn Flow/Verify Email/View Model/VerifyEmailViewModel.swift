//
//  VerifyEmailViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxRelay

class VerifyEmailViewModel: VerifyEmailViewModelCompatible {
    
    private weak var coordinator: SignInFlowCoordinatorable?
    private var signUpService: SignUpServiceable
    private var email: String
    
    var title: String {
        return "Create Account"
    }
    var message: String {
        return "We just need to verify your email address before we can finish the account setup. "
    }
    var showBackButton: Bool {
        return true
    }
    var buttonTitle: String {
        "Continue"
    }
    
    private(set) var inputVerificationcodeViewModel: InputVerificationCodeViewModelCompatible
    
    let bag = DisposeBag()
    
    // MARK: - Input
    
    lazy private(set) var continueTrigger: PublishSubject<Void> = .init()
    lazy private(set) var resendCodeTrigger: PublishSubject<Void>  = .init()
    
    // MARK: - Output
    
    var codeValidationError: Observable<Error?> {
        inputVerificationcodeViewModel.verificationCodeViewModel.validationError
    }
    
    var isValidCode: Observable<Bool> {
        inputVerificationcodeViewModel.isValidCode
    }
    
    // MARK: - Init
    
    init(coordinator: SignInFlowCoordinatorable,
         signUpService: SignUpServiceable,
         userService: UserInfoServiceable,
         email: String,
         type: String = "set") {
        self.coordinator = coordinator
        self.signUpService = signUpService
        self.email = email
        self.inputVerificationcodeViewModel = InputVerificationCodeViewModel(coordinator: coordinator,
                                                                             service: userService,
                                                                             email: email,
                                                                             type: type)
        
        listenTriggers()
    }
    
    // MARK: - Listen triggers
    
    private func listenTriggers() {
        continueTrigger
            .do(onNext: { [weak self] in
                self?.inputVerificationcodeViewModel.verificationCodeViewModel.forceValidate()
            })
            .withLatestFrom(codeValidationError)
            .bind(onNext: { [weak self] error in
                if let code = self?.inputVerificationcodeViewModel.verificationCodeViewModel.code,
                   error == nil {
                    self?.submitCode(code)
                }
            })
            .disposed(by: bag)
        
        resendCodeTrigger
                .bind(to: inputVerificationcodeViewModel.resendCodeTrigger)
                .disposed(by: bag)
    }
    
    // MARK: - Submit code
    
    private func submitCode(_ code: Int) {
        ProgressHUD.show()
        
        signUpService.verifyAccount(with: email,
                                    code: "\(code)",
                                    completion: { [weak self] result in
            ProgressHUD.dismiss()
            
            switch result {
            
            case .success(_):
                self?.continueAfterSuccessfullVerification(email: self?.email ?? "",
                                                           code: "\(code)")
                
            case .failure(let error):
                self?.coordinator?.showError(error: error)
            }
        })
    }
    
    func continueAfterSuccessfullVerification(email: String,
                                              code: String) {
    }
}
