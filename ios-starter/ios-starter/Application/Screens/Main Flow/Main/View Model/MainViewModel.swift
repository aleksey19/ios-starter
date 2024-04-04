//
//  MainViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit
import RxSwift

class MainViewModel: MainViewModelCompatible {
    
    private weak var httpClient: HTTPClient?
    private weak var coordinator: MainFlowCoordinatable?
    
    // MARK: - Output
    
    lazy private(set) var image = PublishSubject<UIImage>()
    
    // MARK: - Init
    
    init(restBackend: HTTPClient,
         coordinator: MainFlowCoordinatable) {
        self.httpClient = restBackend
        self.coordinator = coordinator
    }
    
    func loadImage() {
        let urlString = "http://cdn.motorpage.ru/Photos/800/5D7F.jpg"        
        
        DispatchQueue
            .global(qos: .userInitiated)
            .async { [weak self] in
                self?.httpClient?.downloadImage(with: urlString, completion: { [weak self] result in
                    switch result {
                        
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            self?.image.onNext(image)
                        }
                        
                    case .failure(let error):
                        executeOnMainThread { [weak self] in
                            self?.coordinator?.showError(error: error)
                        }
                    }
                })
            }
    }
}
