//
//  SceneCoordinatorable.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit

protocol SceneCoordinatorable {
    
    var window: UIWindow { get }
    
    func transition(to scene: SceneCompatible,
                    transition: SceneTransition,
                    completion: SceneTransitionCompletion?)
    func start()
    func finish()
}

extension SceneCoordinatorable {
    
    var currentViewController: UIViewController? {
        return self.window.rootViewController?.actualViewController()
    }
    
    var rootViewController: UIViewController? {
        self.window.rootViewController
    }
    
    var isCurrentViewControllerRotatable: Bool {
        return currentViewController is Rotatable
    }
    
    var windowWidth: CGFloat {
        return window.frame.width
    }
    
    var canPerformTransitionForPushNotification: Bool {
        return currentViewController?.navigationController != nil
    }
    
    var currentViewControllerIndex: Int? {
        guard let currentViewController = currentViewController,
            let navigation = currentViewController.navigationController else {
            
            return nil
        }
        
        return navigation.viewControllers.firstIndex(of: currentViewController)
    }
}

protocol FlowSceneCoordinatable {
    var finishCompletion: SceneTransitionCompletion { get }
}

protocol SceneCompatible {
    func viewController() -> UIViewController
}

public typealias SceneTransitionCompletion = (() -> Void)

public protocol SceneTransitionCompatible {
    
    func transition(from currentViewController: UIViewController?,
                    to viewController: UIViewController,
                    window: UIWindow,
                    completion: SceneTransitionCompletion?)
}

// MARK: - actualViewController()

extension UIViewController {
    @objc open func actualViewController() -> UIViewController {
        return self.presentedViewController ?? self
    }
}

extension UINavigationController {
    open override func actualViewController() -> UIViewController {
        return self.presentedViewController ?? self.viewControllers.last?.actualViewController() ?? self
    }
}

extension UITabBarController {
    open override func actualViewController() -> UIViewController {
        return self.presentedViewController ?? self.selectedViewController?.actualViewController() ?? self
    }
}
