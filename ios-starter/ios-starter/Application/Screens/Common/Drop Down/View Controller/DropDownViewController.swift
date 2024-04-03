//
//  DropDownViewController.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit
import RxSwift
import RxDataSources

class DropDownViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var bgView: UIView!
    
    var viewModel: DropDownViewModel! = nil
        
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        bindViewModel()
    }
    
    // MARK: - View setup
    
    private func setupView() {
        bgView.backgroundColor = .mainBg
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 5
        }
        tableView.registerCell(ofType: DropDownItemTableViewCell.self)
        
        setBackgroundColor()
    }
    
    private func setBackgroundColor() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3,
                                      execute: { [weak self] in
            UIView.animate(withDuration: TimeInterval(0.3),
                           animations: { [weak self] in
                self?.view.backgroundColor = .mainBg.withAlphaComponent(0.75)
            })
        })
    }
    
    private func dismiss() {
        let duration = 0.3
        let frame = self.view.frame
        
        // Clear background color
        UIView.animate(
            withDuration: TimeInterval(duration),
            animations: { [weak self] in
                self?.view.backgroundColor = .clear
            },
            completion: nil)
        
        // Play disappear animation
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration / 2,
            execute: {
                UIView.animate(
                    withDuration: 0.4,
                    animations: { [unowned self] in
                        self.view.frame = CGRect(x: 0,
                                                  y: frame.height,
                                                  width: frame.width,
                                                  height: frame.height)
                    },
                    completion: { [weak self] completed in
                        
                        // Dismiss controller
                        if completed {
                            self?.dismiss(animated: false, completion: nil)
                        }
                    })
        })
    }

    // MARK: - Bind view model
    
    private func bindViewModel() {
        let dataSource = RxTableViewSectionedReloadDataSource<DropDownViewModel.ItemModel>(configureCell: { [weak self] (dataSource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(ofType: DropDownItemTableViewCell.self, at: indexPath)
            cell.bind(with: item, selected: self?.viewModel.selectedValue == item)
            
            return cell
        })

        tableView.rx.setDelegate(self).disposed(by: bag)

        viewModel.items.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: bag)

        tableView.rx.itemSelected.bind(to: viewModel.itemSelected).disposed(by: bag)
        
        if let selectedIndex = viewModel.selectedIndex {
            tableView.scrollToRow(at: IndexPath(item: selectedIndex, section: 0), at: .middle, animated: true)
        }
        
        viewModel
            .selectedOptionObservable
            .take(1)
            .bind(onNext: { [weak self] _ in
                self?.dismiss()
            })
            .disposed(by: bag)
    }
    
}

extension DropDownViewController: UIScrollViewDelegate { }
