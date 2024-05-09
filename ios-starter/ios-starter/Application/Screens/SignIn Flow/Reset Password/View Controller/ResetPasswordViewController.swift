//
//  ResetPasswordViewController.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift
import RxDataSources

class ResetPasswordViewController: UIViewController {

    var viewModel: ResetPasswordViewModelCompatible! = nil
    
    private let bag = DisposeBag()
    
    lazy private var tableView: UITableView! = nil
    
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
        navigationController?.isNavigationBarHidden = true
        
        title = "Reset Password"
        
        view.backgroundColor = .mainBg
        
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.registerCell(TextInputTableViewCell.self)
        tableView.registerCell(ButtonTableViewCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Bind view model
    
    private func bindViewModel() {
        let confirmTrigger = viewModel.confirmTrigger
        
        let dataSource = RxTableViewSectionedReloadDataSource<ResetPasswordViewModelCompatible.ItemModel>(configureCell: { [weak self] (dataSource, tableView, indexPath, item) in
            
            switch item.type {
            case .reset:
                let cell = tableView.dequeueReusableCell(ofType: ButtonTableViewCell.self, at: indexPath)
                cell.bind(title: item.name, actionTrigger: confirmTrigger)
                
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

extension ResetPasswordViewController: UIScrollViewDelegate { }
