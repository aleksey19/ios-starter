//
//  UIColor+EightTwenty.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

extension UIColor {
    
    static var mainBg: UIColor {
        return UIColor(named: "lf-deep-ocean") ?? .black
    }
    
    static var accent: UIColor {
        return UIColor(named: "lf-cyan") ?? .systemBlue
    }
    
    static var cardsBg: UIColor {
        return UIColor(named: "lf-seabed-gray") ?? .black//.black.alpha(0.75)
    }
    
    static var divider: UIColor {
        return UIColor(named: "lf-seabed-gray") ?? .black//.alpha(0.5)
    }
    
    static var placeholder: UIColor {
        return UIColor(named: "lf-storm-gray") ?? .darkGray//.alpha(0.25)
    }
    
    static var secondaryText: UIColor {
        return UIColor(named: "lf-storm-gray") ?? .lightGray
    }
    
    static var mainText: UIColor {
        return UIColor(named: "lf-hazy-gray") ?? .white
    }
    
    static var error: UIColor {
        return UIColor(named: "lf-red-cavair") ?? .orange
    }
}
