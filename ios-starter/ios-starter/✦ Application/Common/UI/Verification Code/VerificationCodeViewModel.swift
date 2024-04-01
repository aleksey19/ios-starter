//
//  VerificationCodeViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxRelay

class VerificationCodeViewModel {
    
    let title = "Verification code"
    let codeLength: Int
    
    lazy private(set) var validator = VerificationCodeValidator()
    
    private let bag = DisposeBag()
    
    // MARK: - Input
    lazy private(set) var input: PublishSubject<String> = .init()
    private(set) var code: Int?
                
    // MARK: - Output
    
    lazy private(set) var validationError = self.validationErrorRelay.asObservable()
    lazy private var validationErrorRelay = BehaviorRelay<Error?>(value: nil)
    
    init(codeLength: Int) {
        self.codeLength = codeLength
        
        listenTriggers()
    }
    
    private func listenTriggers() {
        input
            .skip(1)
            .subscribe(onNext: { [weak self] value in
                let error = self?.validator.validate(value, count: self?.codeLength ?? 0)
                self?.validationErrorRelay.accept(error)
                self?.code = Int(value)
            })
            .disposed(by: bag)
    }
    
    func forceValidate() {
        let error = validator.validate("\(self.code ?? 0)", count: codeLength)
        validationErrorRelay.accept(error)
    }
}

extension VerificationCodeValidator {
    func validate(_ value: String, count: Int) -> Error? {
        if value.count < count {
            let error = NSError(domain: errorDomain,
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Verification code must contain \(count) numbers"]) as Error
            return error
        }
        return nil
    }
}
