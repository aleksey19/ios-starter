//
//  SignUpViewController.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift
import RxDataSources

class SignUpViewController: UIViewController {

    var viewModel: SignUpViewModelCompatible! = nil
    
    lazy private var tableView: UITableView! = nil

    private let bag = DisposeBag()

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
        view.backgroundColor = .mainBg
        
        title = "Sign Up"
        
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 0
        tableView.registerCell(TextInputTableViewCell.self)
        tableView.registerCell(RadioButtonsTableViewCell.reuseID)
        tableView.registerCell(StateAndZipTableViewCell.self)
        tableView.registerCell(ButtonTableViewCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Bind view model
    
    private func bindViewModel() {
        let showStatesDropDownTrigger = viewModel.showStateDropDownTrigger
        let showSourceDropDownTrigger = viewModel.showSourceDropDownTrigger
        let signUpTrigger = viewModel.signUpTrigger

        let dataSource = RxTableViewSectionedReloadDataSource<SignUpViewModelCompatible.ItemModel>(
            configureCell: { (dataSource, tableView, indexPath, item) in
            
            switch item.type {
            case .accountType:
                let cell = tableView.dequeueReusableCell(ofType: RadioButtonsTableViewCell.self, at: indexPath)
                if let item = item as? RadioButtonsTableViewCell.ViewModel {
                    cell.bind(viewModel: item)
                }
                
                return cell
                
            case .stateAndZip:
                if let viewModel = item as? StateAndZipSignUpFieldViewModel {
                    let cell = tableView.dequeueReusableCell(ofType: StateAndZipTableViewCell.self, at: indexPath)
                    cell.bind(stateViewModel: viewModel.stateViewModel,
                              showStateDropDownTrigger: showStatesDropDownTrigger,
                              zipViewModel: viewModel.zipViewModel)
                    
                    return cell
                } else {
                    return UITableViewCell()
                }

            case .signUp:
                let cell = tableView.dequeueReusableCell(ofType: ButtonTableViewCell.self, at: indexPath)
                cell.bind(title: item.name, actionTrigger: signUpTrigger)
                
                return cell
                
            case .source:
                let cell = tableView.dequeueReusableCell(ofType: TextInputTableViewCell.self, at: indexPath)
                cell.bindViewModel(item, showDropDownTrigger: showSourceDropDownTrigger)
                
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

extension SignUpViewController: UIScrollViewDelegate { }
