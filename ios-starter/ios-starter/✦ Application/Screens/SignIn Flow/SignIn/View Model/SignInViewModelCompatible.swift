//
//  SignInViewModelCompatible.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxDataSources

protocol SignInViewModelCompatible {
    // Input
    var signInTrigger: PublishSubject<Void> { get }
    var signUpTrigger: PublishSubject<Void> { get }
    var resetPasswordTrigger: PublishSubject<Void> { get }
    
    // Output
    typealias ItemModel = SectionModel<String, SignInFieldViewModel>
    var items: Observable<[ItemModel]> { get }
    
    var validationErrors: Observable<[Error?]> { get }
    var isValidForm: Observable<Bool> { get }
    
    // Func
    func signInWithGoogle(in viewController: UIViewController)
    func signInWithFacebook(in viewController: UIViewController)
    func signInWithApple()
}
