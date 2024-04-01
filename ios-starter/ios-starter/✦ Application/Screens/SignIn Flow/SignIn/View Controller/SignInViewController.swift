//
//  SignInViewController.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SignInViewController: UIViewController {

    var viewModel: SignInViewModelCompatible! = nil
    
    private let bag = DisposeBag()
    
    lazy private var tableView: UITableView! = nil
    
    // MARK: - Init
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeOnKeyboardEvents()
        setupView()
        bindViewModel()
    }
    
    deinit {
        unsubscribeFromKeyboardEvents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Set correct table view header height
        if let headerView = tableView.tableFooterView {

            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableFooterView = headerView
            }
        }
    }

    // MARK: - View setup
    
    private func setupView() {
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .mainBg
        
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.registerCell(ofType: TextInputTableViewCell.self)
        tableView.registerCell(ofType: ButtonTableViewCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        setupTableviewFooter()
    }
    
    private func setupTableviewFooter() {
        let tableFooterView = UIView()
        tableFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        let resetPasswordButton = UIButton(type: .system)
        resetPasswordButton.setUnderlineStyle(with: "Reset Password")
        resetPasswordButton
            .rx
            .controlEvent(.touchUpInside)
            .bind(to: viewModel.resetPasswordTrigger)
            .disposed(by: bag)
        resetPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        
        let signUpButton = UIButton(type: .system)
        signUpButton.setUnderlineStyle(with: "Sign Up")
        signUpButton
            .rx
            .controlEvent(.touchUpInside)
            .bind(to: viewModel.signUpTrigger)
            .disposed(by: bag)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(resetPasswordButton)
        stackView.addArrangedSubview(signUpButton)
        
        tableFooterView.addSubview(stackView)

        let signInWithAppleButton = UIButton(type: .system)
        signInWithAppleButton.setAppleSignInStyle()
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        
        tableFooterView.addSubview(signInWithAppleButton)
        
        let signInWithGoogleButton = UIButton(type: .system)
        signInWithGoogleButton.setGoogleSignInStyle()
        signInWithGoogleButton
            .rx
            .tap
            .bind(onNext: { [weak self] in
                guard let vc = self
                else {
                    return
                }
                
                self?.viewModel.signInWithGoogle(in: vc)
            })
            .disposed(by: bag)
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        
        tableFooterView.addSubview(signInWithGoogleButton)
        
        let signInWithFacebookButton = UIButton(type: .system)
        signInWithFacebookButton.setFacebookSignInStyle()
        signInWithFacebookButton
            .rx
            .tap
            .bind(onNext: { [weak self] in
                guard let vc = self
                else {
                    return
                }
                
                self?.viewModel.signInWithFacebook(in: vc)
            })
            .disposed(by: bag)
        signInWithFacebookButton.translatesAutoresizingMaskIntoConstraints = false
        
        tableFooterView.addSubview(signInWithFacebookButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: tableFooterView.leadingAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: tableFooterView.topAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: tableFooterView.trailingAnchor, constant: -20),
            
            signInWithAppleButton.leadingAnchor.constraint(equalTo: tableFooterView.leadingAnchor, constant: 20),
            signInWithAppleButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: tableFooterView.trailingAnchor, constant: -20),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 50),
            
            signInWithGoogleButton.leadingAnchor.constraint(equalTo: signInWithAppleButton.leadingAnchor),
            signInWithGoogleButton.topAnchor.constraint(equalTo: signInWithAppleButton.bottomAnchor, constant: 12),
            signInWithGoogleButton.trailingAnchor.constraint(equalTo: signInWithAppleButton.trailingAnchor),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 50),
            
            signInWithFacebookButton.leadingAnchor.constraint(equalTo: signInWithAppleButton.leadingAnchor),
            signInWithFacebookButton.topAnchor.constraint(equalTo: signInWithGoogleButton.bottomAnchor, constant: 12),
            signInWithFacebookButton.trailingAnchor.constraint(equalTo: signInWithAppleButton.trailingAnchor),
            signInWithFacebookButton.bottomAnchor.constraint(equalTo: tableFooterView.bottomAnchor, constant: 12),
            signInWithFacebookButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        let view = UIView()
        view.addSubview(tableFooterView)
        
        NSLayoutConstraint.activate([
            tableFooterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableFooterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            tableFooterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        tableView.tableFooterView = view
    }
    
    // MARK: - Bind view model
    
    private func bindViewModel() {
        let signInTrigger = viewModel.signInTrigger
        
        let dataSource = RxTableViewSectionedReloadDataSource<SignInViewModelCompatible.ItemModel>(configureCell: { [weak self] (dataSource, tableView, indexPath, item) in
            
            switch item.type {
            case .signIn:
                let cell = tableView.dequeueReusableCell(ofType: ButtonTableViewCell.self, at: indexPath)
                cell.bind(title: item.name, actionTrigger: signInTrigger)
                
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(ofType: TextInputTableViewCell.self, at: indexPath)
                cell.bind(viewModel: item)
                
                return cell
            }
        })
        
        tableView.rx.setDelegate(self).disposed(by: bag)
        
        viewModel.items.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
    }
}

extension SignInViewController: UIScrollViewDelegate { }
