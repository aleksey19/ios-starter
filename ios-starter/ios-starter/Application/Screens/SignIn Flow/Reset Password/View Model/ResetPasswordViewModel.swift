//
//  ResetPasswordViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources

class ResetPasswordViewModel: ResetPasswordViewModelCompatible {
    private weak var coordinator: SignInFlowCoordinatorable?
    private var signInService: SignInServiceable
    
    // MARK: - Input
    
    lazy private(set) var confirmTrigger: PublishSubject<Void> = .init()
    
    // MARK: - Output
    
    lazy private var itemsRelay: BehaviorRelay<[ItemModel]> = BehaviorRelay(value: [])
    lazy private var validationErrorsRelay = BehaviorRelay<[Error?]>(value: [])
    
    lazy private(set) var items = self.itemsRelay.asObservable()
    lazy private(set) var isValidForm = self.validationErrors.compactMap({ $0.compactMap({ $0 }) }).map({ $0.count == 0 })
    lazy private(set) var validationErrors = self.validationErrorsRelay.asObservable()
    
    // MARK: - Vars
    
    private var fields: [ResetPasswordFieldType] = [.email, .reset]

    private var form: ResetPasswordForm
    
    private let bag = DisposeBag()
    
    // MARK: - Init
    
    init(coordinator: SignInFlowCoordinatorable,
         signInService: SignInServiceable) {
        self.coordinator = coordinator
        self.signInService = signInService
        
        let configureBlock: (([ResetPasswordFieldType]) -> [ResetPasswordFieldViewModel]) = { types in
            return types.map { type in
                return ResetPasswordFieldViewModel(name: type.title(),
                                            placeholder: type.placeholder(),
                                            keyboardType: type.keyboardType(),
                                            validator: type.validator(),
                                            type: type)
            }
        }
        
        form = .init(types: fields,
                           configureBlock: configureBlock)

        listenTriggers()
        makeSections()
    }
    
    // MARK: - Private
    
    private func makeSections() {
        let section = ItemModel(model: "reset_password", items: form.viewModels)
        itemsRelay.accept([section])
    }
    
    private func listenTriggers() {
        form
            .validationErrorObservable
            .bind(to: validationErrorsRelay)
            .disposed(by: bag)
        
        confirmTrigger
            .do(onNext: { [weak self] in
                self?.form.forceValidate()
            })
            .withLatestFrom(isValidForm) { [weak self] (_, isValid) in
                if isValid {
                    self?.resetPassword()
                }
            }
            .subscribe()
            .disposed(by: bag)
    }
    
    private func resetPassword() {
        guard let email = form.email
        else {
            return
        }
        
        coordinator?.showVerification()

//        ProgressHUD.show()
//
//        signInService.sendResetPasswordRequest(with: email,
//                                               completion: { [weak self] (response, error) in
//            ProgressHUD.dismiss()
//
//            if let error = error {
//                self?.coordinator?.showError(error: error)
//            }
//
//            if let _ = response {
//                self?.coordinator?.showVerification()
//            }
//        })
    }
}
