//
//  Scene.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit

enum Scene {
    case splash(SplashViewModel)
    case signIn(SignInViewModel)
    case signUp(SignUpViewModel)
    case resetPassword(ResetPasswordViewModelCompatible)
    case resetPasswordVerificationCode(VerifyEmailViewModelCompatible)
    case dashboard(MainViewModel)
    case tabBarDashboard(MainViewModel, SettingsViewModel)
}

extension Scene: SceneCompatible {
    func viewController() -> UIViewController {
        switch self {
        case .splash(let viewModel):
            let viewController = UIStoryboard(name: "SplashScreen", bundle: nil).instantiateInitialViewController() as? SplashViewController
            viewController?.viewModel = viewModel
            return viewController ?? UIViewController()
            
        case .signIn(let viewModel):
            let viewController = SignInViewController()
            viewController.viewModel = viewModel
            
            let navigationController = BaseNavigationController(rootViewController: viewController)
            
            return navigationController
            
        case .signUp(let viewModel):
            let viewController = SignUpViewController()
            viewController.viewModel = viewModel
            
            return viewController
            
        case .resetPassword(let viewModel):
            let viewController = ResetPasswordViewController()
            viewController.viewModel = viewModel
            
            return viewController
            
        case .resetPasswordVerificationCode(let viewModel):
            let viewController = VerifyEmailViewController()
            viewController.viewModel = viewModel
            
            return viewController
        
        case .dashboard(let viewModel):
            let viewController = MainViewController.instantiateFromNib() as MainViewController
            viewController.viewModel = viewModel
            let navController = BaseNavigationController(rootViewController: viewController)
            navController.setNavigationBarHidden(false, animated: true)
            
            return navController
            
        case .tabBarDashboard(let mainViewModel, let settingsViewModel):
            let mainTabBarItem = UITabBarItem(title: "Main", image: UIImage(systemName: "flag"), tag: 0)
            let mainViewController = MainViewController.instantiateFromNib() as MainViewController
            mainViewController.viewModel = mainViewModel
            let mainNavController = BaseNavigationController(rootViewController: mainViewController)
            mainNavController.tabBarItem = mainTabBarItem

            let settingsTabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 1)
            let settingsViewController = SettingsViewController.instantiateFromNib() as SettingsViewController
            settingsViewController.viewModel = settingsViewModel
            let settingsNavController = BaseNavigationController(rootViewController: settingsViewController)
            settingsNavController.tabBarItem = settingsTabBarItem

            let tabBarController = BaseTabBarViewController()
            tabBarController.viewControllers = [mainNavController, settingsNavController]
            return tabBarController
        }
    }
}

enum CommonScene {
    case alert(AlertViewModel)
    case dropDown(DropDownViewModel)
    case webView(EmbeddedWebViewViewModelCompatible)
}

extension CommonScene: SceneCompatible {
    func viewController() -> UIViewController {
        switch self {
        case .alert(let viewModel):
            let viewController = AlertViewController.instantiateFromNib() as AlertViewController
            viewController.viewModel = viewModel
            return viewController
            
        case .dropDown(let viewModel):
            let viewController = DropDownViewController.instantiateFromNib() as DropDownViewController
            viewController.viewModel = viewModel
                        
            return viewController
            
        case .webView(let viewModel):
            let viewController = EmbeddedWebViewViewController()
            viewController.viewModel = viewModel
            
            let navController = BaseNavigationController(rootViewController: viewController)
            
            return navController
        }
    }
}
