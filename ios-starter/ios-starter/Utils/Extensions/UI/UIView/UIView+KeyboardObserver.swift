//
//  UIView+KeyboardObserver.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

extension UIView {
    func addKeyboardObservers(showHandler:@escaping (_ height: CGFloat) -> Void, hideHandler:@escaping () -> Void) {
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: nil) { notification in
                                                let key = UIResponder.keyboardFrameEndUserInfoKey
                                                let frame: NSValue? = notification.userInfo?[key] as? NSValue
                                                
                                                if let frame = frame {
                                                    let keyboardHeight = frame.cgRectValue.height
                                                    showHandler(keyboardHeight)
                                                }
        }

        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: nil) { _ in
                                                hideHandler()
        }
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
