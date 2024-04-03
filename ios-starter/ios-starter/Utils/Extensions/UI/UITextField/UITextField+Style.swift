//
//  UITextField+Style.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

extension UITextField {
    
    func setStyle(with text: String?,
                     placeholder: String?,
                     textColor: UIColor,
                     placeholderColor: UIColor,
                     textAlignment: NSTextAlignment = .left,
                     shouldSetDefaultTextAttributes: Bool = true) {
        self.text = text
        
        let font = UIFont.getFont(with: .workSans,
                                  style: .regular,
                                  size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18
        paragraphStyle.alignment = textAlignment
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: textColor,
                                                         .backgroundColor: UIColor.clear,
                                                         .paragraphStyle: paragraphStyle]
        var placeholderAttributes = attributes
        placeholderAttributes[.foregroundColor] = placeholderColor

        attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                   attributes: placeholderAttributes)
        
        self.textColor = textColor
        self.typingAttributes = attributes
        
        // Don't set default text attributes for secure text fields to prevent cursor jumping
        if shouldSetDefaultTextAttributes {
            self.defaultTextAttributes = attributes
        } else {
            self.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }
    }
    
    func setInputMoneyStyle() {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "dollar_sign")
        
        let separatorView = UIView()
        separatorView.backgroundColor = .divider
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        leftView.addSubview(imageView)
        leftView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 7),
            imageView.heightAnchor.constraint(equalToConstant: 16),
            imageView.leadingAnchor.constraint(equalTo: leftView.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
            
            separatorView.widthAnchor.constraint(equalToConstant: 2),
            separatorView.heightAnchor.constraint(equalToConstant: 20),
            separatorView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: -8),
            separatorView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
        ])
        
        self.leftView = leftView
        self.leftViewMode = .always
    }
    
    func showRightArrow() {
        let imageView = UIImageView()
        imageView.tintColor = .placeholder
        imageView.image = UIImage(named: "chevron-down")?.withRenderingMode(.alwaysTemplate)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.rightView = imageView
        self.rightViewMode = .always
    }
}
