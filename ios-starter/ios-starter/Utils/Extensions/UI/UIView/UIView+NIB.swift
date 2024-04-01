//
//  UIView+NIB.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

extension UIView {
    
    static func loadFromNIB<T: UIView>() -> T {
        return Bundle.loadView(fromNib: String(describing: self), withType: T.self)
    }
}

extension Bundle {
    
    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing: type))
    }
}
