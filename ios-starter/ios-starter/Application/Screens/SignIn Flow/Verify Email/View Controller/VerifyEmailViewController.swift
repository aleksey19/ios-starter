//
//  VerifyEmailViewController.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift

class VerifyEmailViewController: UIViewController {
    
    private var titleLabel: UILabel! = nil
    private var messageLabel: UILabel! = nil
    private var verificationCodeView: VerificationCodeView! = nil
    private var resendCodeButton: UIButton! = nil
    
    var viewModel: VerifyEmailViewModelCompatible! = nil
    
    private let bag = DisposeBag()
    
    // MARK: - Init
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - View setup
    
    private func setupView() {
        view.backgroundColor = UIColor.mainBg
        
        setupLabels()
        
        let tapGR = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapGR)
    }
    
    private func setupLabels() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.setHeadingStyle(with: .mainPage, text: viewModel.title)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.setParagraphStyle(with: .regular, text: viewModel.message)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(messageLabel)
        
        verificationCodeView = VerificationCodeView.loadFromNIB() as VerificationCodeView
        verificationCodeView.bindViewModel(viewModel.inputVerificationcodeViewModel.verificationCodeViewModel)
        verificationCodeView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(verificationCodeView)
        
        resendCodeButton = UIButton()
        resendCodeButton.isUserInteractionEnabled = true
        resendCodeButton.setUnderlineStyle(with: "Resend verification code")
        resendCodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(resendCodeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            verificationCodeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            verificationCodeView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            verificationCodeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            resendCodeButton.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            resendCodeButton.topAnchor.constraint(equalTo: verificationCodeView.bottomAnchor, constant: 0)
        ])
    }
    
    // MARK: - Bind view model
    
    private func bindViewModel() {
        resendCodeButton
            .rx
            .tap
            .bind(to: viewModel.inputVerificationcodeViewModel.resendCodeTrigger)
            .disposed(by: bag)
    }
}
