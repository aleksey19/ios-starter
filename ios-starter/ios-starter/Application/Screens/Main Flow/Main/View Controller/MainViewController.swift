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
        label.text = "Welcome! By the way, look at this gorgeous emerald car!"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -20)
        ])
        
        bindViewModel()
        
        viewModel.loadImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func bindViewModel() {
        viewModel
            .image
            .observeOn(MainScheduler.instance)
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
    }

}
