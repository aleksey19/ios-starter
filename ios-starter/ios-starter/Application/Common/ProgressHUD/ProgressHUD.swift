//
//  ProgressHUD.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import Lottie

class ProgressHUD: UIView {

    // MARK: - Shared view
        
    private static let shared = ProgressHUD(frame: UIScreen.main.bounds)
    
    private static let appearenceAnimationDuration = TimeInterval(0.3)
    
    // MARK: - Show methods
    
    static func show() {
        self.shared.show()
    }
    
    // MARK: - Dismiss methods
    
    static func dismiss() {
        self.shared.dismiss()
    }
    
    // MARK: - ---Instance Methods--- -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        alpha = 0
    }
    
    // MARK: Animation view
    
    private lazy var animationView: LottieAnimationView? = {
        let view = LottieAnimationView(name: "spinner")
        view.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            view.widthAnchor.constraint(equalToConstant: 80),
            view.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        return view
    }()
    
    // MARK: - Background view
    
    private lazy var backgroundView: UIView? = {
        let view = UIView()
        view.backgroundColor = .mainBg
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        sendSubviewToBack(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        return view
    }()
    
    // MARK: Front window
    
    private var frontWindow: UIWindow? {
        for window in UIApplication.shared.windows.reversed() {
            let isMain = window.screen == UIScreen.main
            let isVisible = !window.isHidden
            let isKey = window.isKeyWindow
            
            if isMain && isVisible && isKey {
                return window
            }
        }
        return nil
    }
    
    // MARK: Update layout
    
    private func updateViewHierarchy() {
        if self.superview == nil {
            self.frontWindow?.addSubview(self)
            self.frontWindow?.bringSubviewToFront(self)
        }
    }
    
    // MARK: - Base show/dismiss methods
    
    private func show() {
        OperationQueue
            .main
            .addOperation { [weak self] in
                UIView.animate(withDuration: Self.appearenceAnimationDuration,
                               animations: { [weak self] in
                    self?.alpha = 1
                    self?.backgroundView?.alpha = 0.84
                    self?.updateViewHierarchy()
                    self?.animationView?.play()
                })
            }
    }
    
    private func dismiss() {
        OperationQueue
            .main
            .addOperation { [weak self] in
                UIView.animate(withDuration: Self.appearenceAnimationDuration,
                               animations: { [weak self] in
                    self?.alpha = 0
                    self?.animationView?.stop()
                    self?.removeFromSuperview()
                })
            }
    }

}
