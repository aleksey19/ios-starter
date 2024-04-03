//
//  BaseNavigationController.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        setDefaultStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setDefaultStyle()
    }
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)

        setFilledNavigationBarBackground(color: .mainBg, show: !hidden)
    }
    
    private func setDefaultStyle() {
        navigationBar.topItem?.hidesBackButton = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .mainBg

        delegate = self
        interactivePopGestureRecognizer?.isEnabled = true

        navigationBar.barTintColor = .mainBg
        navigationBar.tintColor = .mainText
        view.backgroundColor = .mainBg
        
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
                                             NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    @objc func back() {
        if popViewController(animated: true) == nil {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        viewController.navigationItem.hidesBackButton = true

        let backImage = UIImage(named: "back")

        let item = UIBarButtonItem(image: backImage,
                                   style: .plain,
                                   target: self,
                                   action: #selector(back))
        
        viewController.navigationItem.leftBarButtonItems = [item]
    }
}

extension UINavigationController {
    func setFilledNavigationBarBackground(color: UIColor?, show: Bool = true) {
        let identifier = "FilledNavigationBarBackground"

        if show {
            guard
                let fillView = view.subviews.first(where: { $0.restorationIdentifier == identifier })
            else {
                let fillView = UIView()
                fillView.backgroundColor = color
                fillView.alpha = 1
                fillView.frame.origin.x = 0
                fillView.frame.origin.y = 0
                fillView.frame.size.width = view.bounds.size.width
                fillView.frame.size.height = navigationBar.bounds.size.height + view.safeAreaInsets.top + 5
                fillView.restorationIdentifier = identifier

                view.addSubview(fillView)
                view.bringSubviewToFront(navigationBar)

                return
            }

            fillView.backgroundColor = color

            UIView.animate(withDuration: 0.2) {
                fillView.alpha = 1
            }
        } else {
            guard
                let fillView = view.subviews.first(where: { $0.restorationIdentifier == identifier })
            else {
                return
            }

            UIView.animate(withDuration: 0.2,
                           animations: {
                            fillView.alpha = 0
                           },
                           completion: { _ in
                            fillView.removeFromSuperview()
                           })
        }
    }
}
