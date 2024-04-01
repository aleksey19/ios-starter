//
//  SettingsViewController.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit

class SettingsViewController: UIViewController {

    var viewModel: SettingsViewModelCompatible! = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func bindViewModel() {
        
    }
}
