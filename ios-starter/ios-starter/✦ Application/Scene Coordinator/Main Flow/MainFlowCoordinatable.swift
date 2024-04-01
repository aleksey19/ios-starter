//
//  MainCoordinatable.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import Foundation

protocol MainFlowCoordinatable: AnyObject {
    func showMain()
    func pop(toRoot: Bool,
             animated: Bool,
             completion: SceneTransitionCompletion?)
    func showError(error: Error)
}
