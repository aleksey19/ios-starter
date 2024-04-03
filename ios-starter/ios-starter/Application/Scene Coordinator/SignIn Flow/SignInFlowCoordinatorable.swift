//
//  SignInFlowCoordinatorable.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation
import RxSwift

protocol SignInFlowCoordinatorable: AnyObject {
    func showSignIn()
    func showSignUp()
    func showResetPassword()
    func showVerification()
    func finish()
    func showError(error: Error)
    
    func showStateDropDown(with subject: PublishSubject<String>, selectedValue: String?)
    func showAccountTypeDropDown(with subject: PublishSubject<String>, selectedValue: String?)
    func showSignUpReasonDropDown(with subject: PublishSubject<String>,
                                  otherTrigger: PublishSubject<Bool>,
                                  selectedValue: String?)
    
    // Presentation window for apple's ASAuthorizationControllerPresentationContextProviding
    var presentationWindow: UIWindow { get }
}
