//
//  UIFont+ETW.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

extension UIFont {
    
    enum Font: String {
//        case telegraf = "Telegraf"
//        case inputMono = "InputMonoNarrow"
        case workSans = "WorkSans"
    }
    
    enum FontStyle: String {
        case medium = "Medium"
        case regular = "Regular"
        case light = "Light"
        case bold = "Bold"
    }
    
    static func getFont(with type: Font,
                        style: FontStyle,
                        size: CGFloat) -> UIFont {
        let fontFamily = "\(type.rawValue)-\(style.rawValue)"
        return UIFont(name: fontFamily, size: size) ?? .systemFont(ofSize: size)
    }
}
