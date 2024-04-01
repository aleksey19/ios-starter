//
//  AlertViewModel.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

class AlertViewModel {
    
    typealias AlertAction = (() -> Void)
    
    let title: String?
    let message: String?
    let buttonTitle: String
    let action: AlertAction
    let showCheckmarkImage: Bool
    let showRightArrowImage: Bool
    let canDismissOnBackgroundTap: Bool

    init(title: String? = nil,
         message: String? = nil,
         buttonTitle: String = "Ok",
         action: @escaping AlertAction,
         showCheckmarkImage: Bool = true,
         showRightArrowImage: Bool = true,
         canDismissOnBackgroundTap: Bool = true) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
        self.showCheckmarkImage = showCheckmarkImage
        self.showRightArrowImage = showRightArrowImage
        self.canDismissOnBackgroundTap = canDismissOnBackgroundTap
    }
}
