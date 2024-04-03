//
//  MainViewModelCompatible.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation
import RxSwift

protocol MainViewModelCompatible {
    var image: PublishSubject<UIImage> { get }
    
    func loadImage()
}
