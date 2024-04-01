//
//  VerifyEmailViewModelCompatible.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import Foundation
import RxSwift

protocol VerifyEmailViewModelCompatible {
    // Vars
    var title: String { get }
    var message: String { get }
    var inputVerificationcodeViewModel: InputVerificationCodeViewModelCompatible { get }
    
    // Input
    var continueTrigger: PublishSubject<Void> { get }
}
