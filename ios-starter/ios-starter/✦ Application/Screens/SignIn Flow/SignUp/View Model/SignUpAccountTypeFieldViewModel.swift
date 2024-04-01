//
//  SignUpAccountTypeFieldViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift

class SignUpAccountTypeFieldViewModel: SignUpFieldViewModel,
                                       InputFieldRadioButtonViewModelCompatible {
    private(set) var titles: [String] = ["Personal", "Business"]
    private(set) var imageNames: [String]? = nil
    private(set) var selectedValueIndex: Int?

    private let bag = DisposeBag()
    private var selectedAccountType: String?
    
    // Return index of selected value
    override var value: String? {
        guard let selectedAccountType = selectedAccountType,
              let index = titles.firstIndex(of: selectedAccountType) else {
            return nil
        }
        return "\(index)"
    }

    // MARK: - Input
    
    lazy private(set) var input: PublishSubject<Int> = .init()
    
    // MARK: - Init
    
    init(name: String,
         value: String? = nil,
         placeholder: String?,
         keyboardType: UIKeyboardType = .default,
         validator: Validator,
         type: SignUpFieldType,
         isSecureTextEntry: Bool = false,
         isInputAvailable: Bool = true) {
        // Initialize value with default value if needed
//        selectedAccountType = titles.first
        
        super.init(name: name,
                   value: value,
                   placeholder: placeholder,
                   keyboardType: keyboardType,
                   validator: validator,
                   type: type,
                   isSecureTextEntry: isSecureTextEntry)
        
        input
            .bind(onNext: { [weak self] idx in
                self?.selectedAccountType = self?.titles[idx] ?? ""
                self?.selectedValueIndex = idx
            })
            .disposed(by: bag)
    }
}
