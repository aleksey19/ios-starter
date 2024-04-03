//
//  SignUpViewModelCompatible.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxDataSources

protocol SignUpViewModelCompatible {
    // Input
    
    var signInTrigger: PublishSubject<Void> { get }
    var signUpTrigger: PublishSubject<Void> { get }
    var showStateDropDownTrigger: PublishSubject<Void> { get }
    var showSourceDropDownTrigger: PublishSubject<Void> { get }
    
    // Output
    
    typealias ItemModel = SectionModel<String, SignUpFieldViewModel>
    var items: Observable<[ItemModel]> { get }
    
    var validationErrors: Observable<[Error?]> { get }
    var isValidForm: Observable<Bool> { get }
}
