//
//  InputFieldViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxRelay

protocol InputFieldType {
    func title() -> String
    func placeholder() -> String
    func keyboardType() -> UIKeyboardType
}

class InputFieldViewModel {
    
    private(set) var name: String
    private(set) var value: String?
    private(set) var placeholder: String?
    private(set) var keyboardType: UIKeyboardType
    private(set) var validator: Validator
    private(set) var isSecureTextEntry: Bool
    private(set) var isPhoneNumberEntry: Bool
    private(set) var autocorrection: Bool
    private(set) var autocapitalizationType: UITextAutocapitalizationType
    private(set) var isInputAvailable: Bool
    private(set) var inputMask: String?
    
    private(set) var error: Error?
    
    private let bag = DisposeBag()
        
    // MARK: - Output
    
    lazy private(set) var validationErrors = self.validationErrorsRelay.asObservable()
    lazy private var validationErrorsRelay = BehaviorRelay<Error?>(value: nil)
    
    // MARK: - Input

    lazy private(set) var inputValue: PublishSubject<String> = .init()
    
    // MARK: - Init
    
    init(name: String,
         value: String? = nil,
         placeholder: String?,
         keyboardType: UIKeyboardType = .default,
         validator: Validator,
         isSecureTextEntry: Bool = false,
         isPhoneNumberEntry: Bool = false,
         autocorrection: Bool = false,
         autocapitalizationType: UITextAutocapitalizationType = .none,
         isInputAvailable: Bool = true,
         inputMask: String? = nil) {
        self.name = name
        self.value = value
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.validator = validator
        self.isSecureTextEntry = isSecureTextEntry
        self.isPhoneNumberEntry = isPhoneNumberEntry
        self.autocorrection = autocorrection
        self.autocapitalizationType = autocapitalizationType
        self.isInputAvailable = isInputAvailable
        self.inputMask = inputMask
        
        listenTriggers()
    }
    
    // MARK: - Private
    
    private func listenTriggers() {
        validationErrors
            .bind(onNext: { [weak self] error in
                self?.error = error
            })
            .disposed(by: bag)
        
        inputValue
            .bind(onNext: { [weak self] value in
                self?.value = (value.count > 0) ? value : nil
                self?.validate(value: value)
            })
            .disposed(by: bag)
    }
    
    private func validate(value: String) {
        guard let error = validator.validate(value) else {
            validationErrorsRelay.accept(nil)
            self.value = value
            return
        }
        validationErrorsRelay.accept(error)
    }
}

// MARK: - Force validation invoke

extension InputFieldViewModel {
    @objc func forceValidate() {
        validate(value: value ?? "")
    }
}
