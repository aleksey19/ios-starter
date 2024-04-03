//
//  UILabel+Style.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

extension UILabel {
    
    enum HeadingType {
        case mainPage
        case mainPageSmall // For iPhone 8
        case mainPageLight
        case subPage
        case subtitle
    }
    
    enum ParagraphType {
        case regular
        case medium
        case smallRegular
        case smallMedium
        case caption
    }
    
    func setHeadingStyle(with type: HeadingType,
                         text: String?,
                         color: UIColor = UIColor.mainText,
                         alignment: NSTextAlignment = .left) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.04
        paragraphStyle.alignment = alignment
        
        switch type {
        
        case .mainPage:
            set(text: text,
                font: .workSans,
                style: .medium,
                size: 40,
                color: color,
                backgroundColor: .clear,
                kern: -0.8,
                paragraphStyle: paragraphStyle)
            
        case .mainPageLight:
            set(text: text,
                font: .workSans,
                style: .light,
                size: 40,
                color: color,
                backgroundColor: .clear,
                kern: -0.8,
                paragraphStyle: paragraphStyle)
            
        case .mainPageSmall:
            set(text: text,
                font: .workSans,
                style: .medium,
                size: 30,
                color: color,
                backgroundColor: .clear,
                kern: -0.8,
                paragraphStyle: paragraphStyle)
            
        case .subPage:
            set(text: text,
                font: .workSans,
                style: .medium,
                size: 24,
                color: color,
                backgroundColor: .clear,
                paragraphStyle: paragraphStyle)
            
        case .subtitle:
            paragraphStyle.lineHeightMultiple = 1.13
            
            set(text: text,
                font: .workSans,
                style: .medium,
                size: 20,
                color: color,
                backgroundColor: .clear,
                paragraphStyle: paragraphStyle)
        }
    }
    
    func setParagraphStyle(with type: ParagraphType,
                           text: String?,
                           color: UIColor = UIColor.mainText,
                           alignment: NSTextAlignment = .left) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18
        paragraphStyle.alignment = alignment
        
        switch type {
        case .regular, .smallRegular:
            let size: CGFloat = type == .regular ? 16 : 14
            
            set(text: text,
                font: .workSans,
                style: .regular,
                size: size,
                color: color,
                backgroundColor: .clear,
                paragraphStyle: paragraphStyle)
            
        case .medium, .smallMedium:
            let size: CGFloat = type == .regular ? 16 : 14
            
            set(text: text,
                font: .workSans,
                style: .medium,
                size: size,
                color: color,
                backgroundColor: .clear,
                paragraphStyle: paragraphStyle)
            
        case .caption:
            paragraphStyle.lineHeightMultiple = 1.04
            
            set(text: text,
                font: .workSans,
                style: .light,
                size: 12,
                color: color,
                backgroundColor: .clear,
                kern: -0.3,
                paragraphStyle: paragraphStyle)
        }
    }
    
    func setTextStyle(text: String?,
                      color: UIColor = UIColor.mainText,
                      underline: Bool = false) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18
        
        set(text: text,
            font: .workSans,
            style: .regular,
            size: 16,
            color: color,
            backgroundColor: .clear,
            paragraphStyle: paragraphStyle,
            underline: underline)
    }
    
    func setOverlineTextStyle(text: String?,
                              color: UIColor = UIColor.mainText) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.83
        
        set(text: text,
            font: .workSans,
            style: .medium,
            size: 10,
            color: color,
            backgroundColor: .clear,
            paragraphStyle: paragraphStyle)
    }
    
    private func set(text: String?,
                     font: UIFont.Font,
                     style: UIFont.FontStyle,
                     size: CGFloat,
                     color: UIColor,
                     backgroundColor: UIColor,
                     kern: CGFloat = 0,
                     paragraphStyle: NSParagraphStyle,
                     underline: Bool = false) {
        let font = UIFont.getFont(with: font, style: style, size: size)
        
        var attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: color,
                                                         .backgroundColor: backgroundColor,
                                                         .kern: kern,
                                                         .paragraphStyle: paragraphStyle]
        if underline == true {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.underlineColor] = color
        }
        
        // Hack
        var string: String?

        if text?.contains("\n") == true {
            let modifiedText = text?.replacingOccurrences(of: "\n", with: "\n\n")
            string = modifiedText
        } else {
            string = text
        }
        
        self.attributedText = NSAttributedString(string: string ?? "",
                                                 attributes: attributes)
    }
}

// MARK: - Custom styles

extension UILabel {
    
    func setTabBarTextStyle(text: String?,
                            color: UIColor = UIColor.mainText) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.83
        paragraphStyle.alignment = .center
        
        set(text: text,
            font: .workSans,
            style: .medium,
            size: 11,
            color: color,
            backgroundColor: .clear,
            paragraphStyle: paragraphStyle)
    }
}
