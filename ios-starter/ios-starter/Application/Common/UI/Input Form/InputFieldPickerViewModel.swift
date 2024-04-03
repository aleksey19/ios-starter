//
//  InputFieldPickerViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift

protocol InputFieldPickerViewModelCompatible {
    var valuesObservable: Observable<[String]> { get }
}
