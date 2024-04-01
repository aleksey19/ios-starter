//
//  StateAndZipSignUpFieldViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift

class StateAndZipSignUpFieldViewModel: SignUpFieldViewModel {
    
    private(set) var stateViewModel: SignUpStateFieldViewModel
    private(set) var zipViewModel: SignUpFieldViewModel
    
    init(stateViewModel: SignUpStateFieldViewModel,
         zipViewModel: SignUpFieldViewModel) {
        self.stateViewModel = stateViewModel
        self.zipViewModel = zipViewModel
        
        super.init(name: "", placeholder: "", validator: EmptyValidator(), type: .stateAndZip)
    }
    
    override func forceValidate() {
        stateViewModel.forceValidate()
        zipViewModel.forceValidate()
    }
    
    /// Combine validation errors from view models into single observable
    override var validationErrors: Observable<Error?> {
        Observable
            .combineLatest([stateViewModel.validationErrors, zipViewModel.validationErrors])
            .map({ errors in
                guard let error = errors.first(where: { $0 != nil }) else {
                    return nil
                }
                return error
            })
    }
}
