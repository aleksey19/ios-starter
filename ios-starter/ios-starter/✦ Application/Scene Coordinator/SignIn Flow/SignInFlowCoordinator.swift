//
//  SignInCoordinator.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit
import RxSwift

final class SignInFlowCoordinator: SceneCoordinator, FlowSceneCoordinatable {
    
    private weak var _session: AppSession?
    internal var finishCompletion: SceneTransitionCompletion
    
    override func start() {
        showSignIn()
    }
    
    override func finish() {
        finishCompletion()
    }
    
    // MARK: - Init
    
    init(window: UIWindow,
         session: AppSession,
         isActiveSession: Bool = false,
         finishCompletion: @escaping SceneTransitionCompletion) {
        self.finishCompletion = finishCompletion
        self._session = session
        
        super.init(window: window,
                   session: session,
                   isActiveSession: false)
    }
}

extension SignInFlowCoordinator: SignInFlowCoordinatorable {
    
    // Presentation window for apple's ASAuthorizationControllerPresentationContextProviding
    var presentationWindow: UIWindow {
        return self.window
    }
    
    var session: AppSession {
        guard let session = self._session
        else {
            fatalError("SignInFlowCoordinator. Can't get app session")
        }
        return session
    }
    
    // MARK: - SignInFlowCoordinatorable
    
    func showSignIn() {
        let service = SignInService(restBackend: session.appRESTBackend)
        let viewModel = SignInViewModel(coordinator: self,
                                        signInService: service)
        
        self.transition(to: Scene.signIn(viewModel),
                        transition: .root)
    }
    
    func showSignUp() {
        let service = SignUpService(restBackend: session.appRESTBackend)
        let viewModel = SignUpViewModel(coordinator: self,
                                        signUpService: service)
        
        self.transition(to: Scene.signUp(viewModel),
                        transition: .push)
    }
    
    func showResetPassword() {
        let service = SignInService(restBackend: session.appRESTBackend)
        let viewModel = ResetPasswordViewModel(coordinator: self,
                                               signInService: service)

        self.transition(to: Scene.resetPassword(viewModel),
                        transition: .push)
    }
    
    func showVerification() {
        let service = SignUpService(restBackend: session.appRESTBackend)
        let userService = UserInfoService(restBackend: session.appRESTBackend)
        let viewModel = VerifyEmailToChangePasswordViewModel(coordinator: self,
                                                             signUpService: service,
                                                             userService: userService,
                                                             email: "email")

        transition(to: Scene.resetPasswordVerificationCode(viewModel), transition: .push)
    }
        
    func showError(error: Error) {
        super.showError(error: error)
    }
    
    // Drop down
    
    func showStateDropDown(with subject: PublishSubject<String>, selectedValue: String?) {
        let options = [
            "AK", "AL", "AR", "AS", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "FM", "GA", "GU", "HI",
            "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MH", "MI", "MN", "MO", "MP",
            "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "PR",
            "PW", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VI", "VT", "WA", "WI", "WV", "WY",
        ]
        
        showOptionsDropDown(with: subject, options: options, selectedValue: selectedValue)
    }
    
    func showAccountTypeDropDown(with subject: PublishSubject<String>, selectedValue: String? = nil) {
        let options = ["Personal", "Business"]
        
        showOptionsDropDown(with: subject, options: options, selectedValue: selectedValue)
    }
    
    func showSignUpReasonDropDown(with subject: PublishSubject<String>,
                                  otherTrigger: PublishSubject<Bool>,
                                  selectedValue: String? = nil) {
        let options = ["Website", "Referral Link", "Social Media", "Other"]
        
        showOptionsDropDown(with: subject,
                            lastOptionSelectedTrigger: otherTrigger,
                            options: options,
                            selectedValue: selectedValue)
    }
}
