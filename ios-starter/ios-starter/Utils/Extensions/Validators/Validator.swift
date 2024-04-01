//
//  Validator.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation

protocol Validator {
    var errorDomain: String { get }
    func validate(_ value: String) -> Error?
}

protocol CompareValuesValidator: Validator {
    func validate(_ value: String, comparedValue: String) -> Error?
}
