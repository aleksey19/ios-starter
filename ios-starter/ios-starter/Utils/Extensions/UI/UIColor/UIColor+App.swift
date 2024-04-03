//
//  UIColor+EightTwenty.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

extension UIColor {
    
    static var mainBg: UIColor {
        return UIColor(named: "deep-ocean") ?? .black
    }
    
    static var accent: UIColor {
        return UIColor(named: "cyan") ?? .systemBlue
    }
    
    static var cardsBg: UIColor {
        return UIColor(named: "seabed-gray") ?? .black//.black.alpha(0.75)
    }
    
    static var divider: UIColor {
        return UIColor(named: "seabed-gray") ?? .black//.alpha(0.5)
    }
    
    static var placeholder: UIColor {
        return UIColor(named: "storm-gray") ?? .darkGray//.alpha(0.25)
    }
    
    static var secondaryText: UIColor {
        return UIColor(named: "storm-gray") ?? .lightGray
    }
    
    static var mainText: UIColor {
        return UIColor(named: "hazy-gray") ?? .white
    }
    
    static var error: UIColor {
        return UIColor(named: "red-cavair") ?? .orange
    }
}
