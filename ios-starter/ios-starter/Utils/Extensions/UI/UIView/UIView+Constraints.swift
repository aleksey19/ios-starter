//
//  UIView+Constraints.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

extension UIView {
    func constraintsToParent(view: UIView, at: Int? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if let at = at {
            view.insertSubview(self, at: at)
        } else {
            view.addSubview(self)
        }
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
