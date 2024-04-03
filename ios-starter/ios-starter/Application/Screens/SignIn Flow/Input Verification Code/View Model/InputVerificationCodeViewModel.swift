//
//  InputVerificationCodeViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxRelay

class InputVerificationCodeViewModel: InputVerificationCodeViewModelCompatible {
    
    private weak var coordinator: SignInFlowCoordinatorable?
    private let service: UserInfoServiceable
    private let email: String
    private let type: String
    
    private(set) var verificationCodeViewModel: VerificationCodeViewModel
    
    let bag = DisposeBag()
    
    // MARK: - Input
    
    lazy private(set) var resendCodeTrigger: PublishSubject<Void>  = .init()
        
    // MARK: - Output
    
    var codeValidationError: Observable<Error?> {
        verificationCodeViewModel.validationError
    }
    
    lazy private(set) var isValidCode: Observable<Bool> = self.codeValidationError.map({ $0 == nil })
    
    // MARK: - Init
    
    init(coordinator: SignInFlowCoordinatorable,
         service: UserInfoServiceable,
         email: String,
         type: String) {
        self.coordinator = coordinator
        self.service = service
        self.email = email
        self.type = type
        self.verificationCodeViewModel = .init(codeLength: 4)

        listenTriggers()
//        sendCode()
    }
    
    // MARK: - Listen triggers
    
    private func listenTriggers() {        
        resendCodeTrigger
            .bind(onNext: { [weak self] in
                self?.sendCode()
            })
            .disposed(by: bag)
    }
    
    // MARK: - Private
    
    private func sendCode() {
        ProgressHUD.show()

        service.requestCode(email: email,
                            type: type,
                            completion: { [weak self] result in
            ProgressHUD.dismiss()

            switch result {
            
            case .success(_):
                return
                
            case .failure(let error):
                self?.coordinator?.showError(error: error)
            }
        })
    }
}
