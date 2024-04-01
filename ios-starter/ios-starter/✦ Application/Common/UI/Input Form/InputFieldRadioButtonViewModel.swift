//
//  RadioButtonViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift

protocol InputFieldRadioButtonViewModelCompatible {
    var titles: [String] { get }
    var imageNames: [String]? { get }
    var input: PublishSubject<Int> { get }
    var selectedValueIndex: Int? { get }
}
