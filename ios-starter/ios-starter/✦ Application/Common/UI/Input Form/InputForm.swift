//
//  InputCardForm.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxRelay

class InputForm<FieldType: InputFieldType, InputViewModel: InputFieldViewModel> {
    
    private(set) var viewModels: [InputViewModel]
    
    lazy private(set) var isValidObservable = self.validationErrors.map({ $0.count == 0 }).asObservable()
    lazy private(set) var validationErrorObservable = self.validationErrors.asObservable()
    lazy private var validationErrors = BehaviorRelay<[Error?]>(value: [])
    
    private let bag = DisposeBag()
    
    
    init(types: [FieldType], configureBlock: (([FieldType]) -> [InputViewModel])) {
        viewModels = configureBlock(types)
        
        Observable
            .combineLatest(viewModels.map({ $0.validationErrors }))
            .bind(to: validationErrors)
            .disposed(by: bag)
    }
}

// MARK: - Force validation invoke

extension InputForm {
    func forceValidate() {
        viewModels.forEach({ $0.forceValidate() })
    }
}
