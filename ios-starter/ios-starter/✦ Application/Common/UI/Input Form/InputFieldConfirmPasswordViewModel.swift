//
//  ConfirmPasswordInputFieldViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift
import RxRelay

protocol InputFieldConfirmPasswordViewModelCompatible {
    var inputPasswords: PublishSubject<(String, String)> { get }
}
