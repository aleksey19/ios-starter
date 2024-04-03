//
//  ResetPasswordViewModelCompatible.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxDataSources

protocol ResetPasswordViewModelCompatible {
    // Input
    var confirmTrigger: PublishSubject<Void> { get }
    
    // Output
    typealias ItemModel = SectionModel<String, ResetPasswordFieldViewModel>
    var items: Observable<[ItemModel]> { get }
    
    var validationErrors: Observable<[Error?]> { get }
    var isValidForm: Observable<Bool> { get }
}
