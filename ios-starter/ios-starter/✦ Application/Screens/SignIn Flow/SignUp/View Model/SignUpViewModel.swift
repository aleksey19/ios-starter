//
//  SignUpViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxRelay

class SignUpViewModel: SignUpViewModelCompatible {
    private weak var coordinator: SignInFlowCoordinatorable?
    private var signUpService: SignUpServiceable
    
    // MARK: - Input
    
    lazy private(set) var signInTrigger: PublishSubject<Void> = .init()
    lazy private(set) var signUpTrigger: PublishSubject<Void> = .init()
    lazy private(set) var showAccountTypeDropDownTrigger: PublishSubject<Void> = .init()
    lazy private(set) var showStateDropDownTrigger: PublishSubject<Void> = .init()
    lazy private(set) var showSourceDropDownTrigger: PublishSubject<Void> = .init()

    var continueTrigger: PublishSubject<Void> {
        return signUpTrigger
    }
    
    lazy private(set) var showCustomSourceTrigger: PublishSubject<Bool> = .init()
    
    // MARK: - Output

    lazy private var itemsRelay: BehaviorRelay<[ItemModel]> = BehaviorRelay(value: [])
    lazy private var validationErrorsRelay = BehaviorRelay<[Error?]>(value: [])
    
    lazy private(set) var items = self.itemsRelay.asObservable()
    lazy private(set) var isValidForm = self.validationErrors.compactMap({ $0.compactMap({ $0 }) }).map({ $0.count == 0 })
    lazy private(set) var validationErrors = self.validationErrorsRelay.asObservable()
    
    // MARK: - Vars
    
    private lazy var configureBlock: (([SignUpFieldType]) -> [SignUpFieldViewModel]) = { types in
        // Indicates that new view model should be created and old copy should be replaced with new one.
        // This allows to add/remove only "Other source" view model and keep others.
        let shouldCreateNewViewModelIfOldExist = false
        
        return types.map { [weak self] type in
            let value = self?.signUpForm?.value(for: type)
            
            if shouldCreateNewViewModelIfOldExist == false,
               let viewModel = self?.signUpForm?.viewModels.first(where: { $0.type == type }) {
                return viewModel
            }
            
            switch type {
            case .accountType:
                return SignUpAccountTypeFieldViewModel(name: type.title(),
                                                       placeholder: type.placeholder(),
                                                       validator: type.validator(),
                                                       type: type)
            case .stateAndZip:
                let stateType = SignUpFieldType.state
                let stateViewModel = SignUpStateFieldViewModel(name: stateType.title(),
                                                               placeholder: stateType.placeholder(),
                                                               keyboardType: stateType.keyboardType(),
                                                               validator: stateType.validator(),
                                                               type: stateType)
                
                let zipType = SignUpFieldType.zip
                let zipViewModel = SignUpFieldViewModel(name: zipType.title(),
                                                        placeholder: zipType.placeholder(),
                                                        keyboardType: zipType.keyboardType(),
                                                        validator: zipType.validator(),
                                                        type: type,
                                                        inputMask: String.postalCodeMask)
                                    
                return StateAndZipSignUpFieldViewModel(stateViewModel: stateViewModel,
                                                       zipViewModel: zipViewModel)

            default:
                var autocapitalizationType = UITextAutocapitalizationType.none

                switch type {
                case .fullName:
                    autocapitalizationType = .words
                case .address, .address2, .city, .customSource:
                    autocapitalizationType = .sentences
                default:
                    break
                }
                
                return SignUpFieldViewModel(name: type.title(),
                                            placeholder: type.placeholder(),
                                            keyboardType: type.keyboardType(),
                                            validator: type.validator(),
                                            type: type,
                                            isSecureTextEntry: false,
                                            isPhoneNumberEntry: type == .phone,
                                            autocapitalizationType: autocapitalizationType)
            }
        }
    }

    private var fields: [SignUpFieldType] = [.fullName, .address, .address2, .city, .stateAndZip, .accountType, .phone, .source, .signUp]

    private var signUpForm: SignUpForm! = nil

    private var bag = DisposeBag()

    // MARK: - Init
    
    init(coordinator: SignInFlowCoordinatorable,
         signUpService: SignUpServiceable) {
        self.coordinator = coordinator
        self.signUpService = signUpService

        initForm()
        listenTriggers()
        makeSections()
    }
    
    // MARK: - Listen triggers
    
    private func listenTriggers() {
        signUpForm
            .validationErrorObservable
            .bind(to: validationErrorsRelay)
            .disposed(by: bag)
        
        signUpTrigger
            .do(onNext: { [weak self] in
                self?.signUpForm.forceValidate()
            })
            .withLatestFrom(isValidForm) { [weak self] (_, isValid) in
                if isValid {
                    self?.signUp()
                }
            }
            .subscribe()
            .disposed(by: bag)
        
        signInTrigger
            .bind(onNext: { [weak self] in
                self?.signInTapped()
            })
            .disposed(by: bag)
        
        showCustomSourceTrigger
            .distinctUntilChanged()
            .bind(onNext: { [weak self] show in
                self?.editInputForm(showOtherSource: show)
            })
            .disposed(by: bag)
        
        let showCustomSourceTrigger = self.showCustomSourceTrigger
        if let viewModel = signUpForm.viewModels.first(where: { $0.type == .source }) {
            showSourceDropDownTrigger
                .bind(onNext: { [weak self] in
                    self?.coordinator?.showSignUpReasonDropDown(with: viewModel.inputValue,
                                                                otherTrigger: showCustomSourceTrigger,
                                                                selectedValue: viewModel.value)
                })
                .disposed(by: bag)
        }
        
        if let viewModel = signUpForm.viewModels.first(where: { $0.type == .stateAndZip }) as? StateAndZipSignUpFieldViewModel {
            let stateViewModel = viewModel.stateViewModel
            
            showStateDropDownTrigger
                .bind(onNext: { [weak self] in
                    self?.coordinator?.showStateDropDown(with: stateViewModel.inputValue,
                                                         selectedValue: stateViewModel.value)
                })
                .disposed(by: bag)
        }
    }

    // MARK: - Private
    
    private func initForm() {
        signUpForm = .init(types: fields,
                           configureBlock: configureBlock)
    }
    
    private func reloadForm() {
        bag = DisposeBag()
        
        initForm()
        makeSections()
        listenTriggers()
    }
    
    private func makeSections() {
        let section = ItemModel(model: "sign_up", items: signUpForm.viewModels)
        itemsRelay.accept([section])
    }

    private func signUp() {
        let credentials = signUpForm.createRegistrationDataObject()
        
        signUpService
            .signUp(with: credentials,
                    completion: { [weak self] (token, error) in
                if let error = error {
                    self?.coordinator?.showError(error: error)
                }
                
                if let response = token {
                    self?.coordinator?.finish()
                }
            })
    }
    
    private func signInTapped() {
        coordinator?.showSignIn()
    }
    
    // MARK: - Show/Remove "How did you hear about us? (Other)" cell
    
    private func editInputForm(showOtherSource: Bool) {
        if showOtherSource == true {
            if fields.contains(.customSource) == false {
                let index = fields.firstIndex(of: .source) ?? 0
                fields.insert(.customSource, at: index + 1)
                reloadForm()
            }
        } else if fields.contains(.source) {
            fields.removeAll(where: { $0 == .customSource })
            reloadForm()
        }
    }
}
