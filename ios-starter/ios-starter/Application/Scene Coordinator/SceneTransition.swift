//
//  SceneTransition.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit

enum SceneTransition {
    case root
    case push
    case modal
    case modalInContext
}

extension SceneTransition: SceneTransitionCompatible {
    func transition(from currentViewController: UIViewController?,
                    to viewController: UIViewController,
                    window: UIWindow,
                    completion: SceneTransitionCompletion? = nil) {
        switch self {
        
        case .root:
            window.rootViewController = viewController
            completion?()
            
        case .push:
            let navigationController: UINavigationController

            if let controller = currentViewController?.navigationController {
                navigationController = controller
            } else if let controller = currentViewController as? UINavigationController {
                navigationController = controller
            } else {
                fatalError("🚫 Can't process push transition without navigation controller")
            }
            
            viewController.hidesBottomBarWhenPushed = true
            
            executeOnMainThread {
                CATransaction.begin()
                navigationController.pushViewController(viewController, animated: true)
                CATransaction.setCompletionBlock {
                    completion?()
                }
                CATransaction.commit()
            }
                        
        case .modal:
            guard let currentViewController = currentViewController else {
                fatalError("🚫 Can't process modal transition without current view controller")
            }
            
            viewController.modalPresentationStyle = .fullScreen
            
            executeOnMainThread {
                currentViewController.present(viewController,
                                              animated: true,
                                              completion: completion)
            }
            
        case .modalInContext:
            guard let currentViewController = currentViewController else {
                fatalError("🚫 Can't process modalInContext transition without current view controller")
            }
            
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overFullScreen
            
            executeOnMainThread {
                currentViewController.present(viewController,
                                              animated: true,
                                              completion: completion)
            }
        }
    }
}
