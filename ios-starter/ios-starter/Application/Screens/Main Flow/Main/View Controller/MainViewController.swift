//
//  MainViewController.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit
import RxSwift

class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
        
    var viewModel: MainViewModelCompatible! = nil
    
    private let bag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Main"
        
        view.backgroundColor = .systemBlue
        
        let label = UILabel()
        label.text = "Welcome!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -20)
        ])
        
        viewModel.loadImage()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func bindViewModel() {
        viewModel
            .image
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
    }

}
