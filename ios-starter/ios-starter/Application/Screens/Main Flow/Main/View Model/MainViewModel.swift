//
//  MainViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit
import RxSwift

class MainViewModel: MainViewModelCompatible {
    
    lazy private(set) var image = PublishSubject<UIImage>()
    
    private weak var httpClient: HTTPClient?
    
    // MARK: - Init
    
    init(restBackend: HTTPClient) {
        self.httpClient = restBackend
    }
    
    func loadImage() {
        let urlString = "http://cdn.motorpage.ru/Photos/800/5D7F.jpg"        
        
        DispatchQueue
            .global(qos: .userInitiated)
            .async { [weak self] in
//                self?.httpClient.image(url: urlString) { [weak self] (data, error) in
//                    if let data = data,
//                       let image = UIImage(data: data) {
//                        self?.image.onNext(image)
//                    }
//                }
            }
    }
}
