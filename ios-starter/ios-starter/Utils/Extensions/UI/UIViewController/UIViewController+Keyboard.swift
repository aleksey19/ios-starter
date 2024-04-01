//
//  UIViewController+Keyboard.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

// MARK: - Keyboard handling

extension UIViewController {
    
    func subscribeOnKeyboardEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object:nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object:nil)
    }
    
    func unsubscribeFromKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        // Hack to prevent keyboard showing when present custom modal drop down
        if keyboardHeight < 100 {
            scrollViewSubview?.contentInset = .zero
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        scrollViewSubview?.contentInset = contentInsets
    }
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification) {
        scrollViewSubview?.contentInset = .zero
    }
    
    var scrollViewSubview: UIScrollView? {
        return view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
}
