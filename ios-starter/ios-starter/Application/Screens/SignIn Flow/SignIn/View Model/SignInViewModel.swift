//
//  SignInViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxDataSources
import RxRelay
import FirebaseCore
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices
import CryptoKit

class SignInViewModel: NSObject, SignInViewModelCompatible {
    private weak var coordinator: SignInFlowCoordinatorable?
    private var signInService: SignInServiceable
    
    // MARK: - Input
    
    lazy private(set) var email: BehaviorSubject<String?> = .init(value: nil)
    lazy private(set) var password: BehaviorSubject<String?> = .init(value: nil)
    
    lazy private(set) var signInTrigger: PublishSubject<Void> = .init()
    lazy private(set) var signUpTrigger: PublishSubject<Void> = .init()
    lazy private(set) var resetPasswordTrigger: PublishSubject<Void> = .init()

    // MARK: - Output
    
    lazy private var itemsRelay: BehaviorRelay<[ItemModel]> = BehaviorRelay(value: [])
    lazy private var validationErrorsRelay = BehaviorRelay<[Error?]>(value: [])
    
    lazy private(set) var items = self.itemsRelay.asObservable()
    lazy private(set) var isValidForm = self.validationErrors.compactMap({ $0.compactMap({ $0 }) }).map({ $0.count == 0 })
    lazy private(set) var validationErrors = self.validationErrorsRelay.asObservable()
    
    // MARK: - Func
    
    func signInWithGoogle(in viewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
    }
    
    func signInWithFacebook(in viewController: UIViewController) {
        LoginManager().logIn(permissions: ["email"], from: viewController) { [weak self] (result, error) in
            
            if let token = result?.token {
                self?.coordinator?.finish()
            }
            
            if let error = error {
                self?.coordinator?.showError(error: error)
            }
        }
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?

    func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Vars
    
    private var fields: [SignInFieldType] = [.email, .passsword, .signIn]
    
    private var form: SignInForm
    
    private let bag = DisposeBag()
    
    // MARK: - Init
    
    init(coordinator: SignInFlowCoordinatorable,
         signInService: SignInServiceable) {
        self.coordinator = coordinator
        self.signInService = signInService
        
        let configureBlock: (([SignInFieldType]) -> [SignInFieldViewModel]) = { types in
            return types.map { type in
                return SignInFieldViewModel(name: type.title(),
                                            placeholder: type.placeholder(),
                                            keyboardType: type.keyboardType(),
                                            validator: type.validator(),
                                            type: type,
                                            isSecureTextEntry: type == .passsword)
            }
        }
        
        form = .init(types: fields,
                           configureBlock: configureBlock)
        
        super.init()
        
        listenTriggers()
        makeSections()
    }

    // MARK: - Private
    
    private func makeSections() {
        let section = ItemModel(model: "sign_in", items: form.viewModels)
        itemsRelay.accept([section])
    }
    
    private func listenTriggers() {
        form
            .validationErrorObservable
            .bind(to: validationErrorsRelay)
            .disposed(by: bag)
        
        signInTrigger
            .do(onNext: { [weak self] in
                self?.form.forceValidate()
            })
            .withLatestFrom(isValidForm) { [weak self] (_, isValid) in
                if isValid {
                    self?.signIn()
                }
            }
            .subscribe()
            .disposed(by: bag)
        
        signUpTrigger
            .bind(onNext: { [weak self] in
                self?.signUpTapped()
            })
            .disposed(by: bag)
        
        resetPasswordTrigger
            .bind(onNext: { [weak self] in
                self?.resetPasswordTapped()
            })
            .disposed(by: bag)
    }
    
    private func signIn() {
//        coordinator?.finish()
//        return
        
        ProgressHUD.show()
        
        signInService
            .signIn(with: (try? email.value()) ?? "",
                    password: (try? password.value()) ?? "") { [weak self] result in
                ProgressHUD.dismiss()
                
                switch result {
                case .success(let response):
                    if let token = response.data {
                        self?.coordinator?.finish()
                    }
                    
                case .failure(let error):
                    self?.coordinator?.showError(error: error)
                }
            }
    }
    
    private func signUpTapped() {
        coordinator?.showSignUp()
    }
    
    private func resetPasswordTapped() {
        coordinator?.showResetPassword()
    }
    
    // MARK: - Private. Apple sign in utilities
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension SignInViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            coordinator?.finish()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension SignInViewModel: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = coordinator?.presentationWindow
        else {
            fatalError("No presentation window for sign in coordinator for ASAuthorizationControllerPresentationContextProviding")
        }
        
        return window
    }
}
