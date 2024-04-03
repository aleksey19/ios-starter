//
//  UIButton+Style.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

extension UIButton {
    
    enum ButtonStyle {
        case filled
        case outline
    }
    
    func set(style: ButtonStyle,
             showRightImage: Bool = false,
             text: String? = nil,
             color: UIColor = .mainText) {
        switch style {
        case .filled:
            setFilledStyle(with: text, showRightImage: showRightImage)
        case .outline:
            setOutlineStyle(with: text, showRightImage: showRightImage, color: color)
        }
        
        roundCornersAndCenterContent()
    }
    
    func setRadioButtonType(isSelected: Bool) {
        backgroundColor = isSelected ? .mainText : .cardsBg
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
        
        let font = UIFont.getFont(with: .workSans,
                                  style: .medium,
                                  size: 10)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.83
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: isSelected ? UIColor.black : UIColor.secondaryText,
                                                         .backgroundColor: UIColor.clear,
                                                         .kern: 0.7,
                                                         .paragraphStyle: paragraphStyle]
        let attributedText = NSAttributedString(string: title(for: .normal)?.uppercased() ?? "",
                                                attributes: attributes)
        
        setAttributedTitle(attributedText, for: .normal)
        
        imageView?.tintColor = isSelected ? .cardsBg : .mainText
    }
    
    private func setFilledStyle(with text: String?,
                                showRightImage: Bool = false) {
        let font = UIFont.getFont(with: .workSans,
                                  style: .medium,
                                  size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.83
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: UIColor.mainText,
                                                         .backgroundColor: UIColor.clear,
                                                         .kern: 0.7,
                                                         .paragraphStyle: paragraphStyle]
        
        let attributedText = NSAttributedString(string: text ?? "",
                                                attributes: attributes)
        
        setAttributedTitle(attributedText, for: .normal)
        
        //        setTitle(text, for: .normal)
        //        titleLabel?.font = font
        //        setTitleColor(.mainText, for: .normal)
        
        backgroundColor = .accent
        
        if showRightImage == true,
           let titleLabel = titleLabel {
            let imageView = UIImageView(image: UIImage(named: "arrow-right")?.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = UIColor.mainBg
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 20),
                imageView.widthAnchor.constraint(equalToConstant: 16),
                imageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 0),
                imageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10)
            ])
            
            titleEdgeInsets.right = 25
        }
        
        titleEdgeInsets.top = 1
    }
    
    private func setOutlineStyle(with text: String?,
                                 showRightImage: Bool = false,
                                 color: UIColor = UIColor.mainText) {
        layer.borderWidth = 2
        layer.borderColor = color.cgColor
        
        let font = UIFont.getFont(with: .workSans,
                                  style: .medium,
                                  size: 14)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.83
        
        //        let attributes: [NSAttributedString.Key: Any] = [.font: font,
        //                                                         .foregroundColor: UIColor.mainText,
        //                                                         .backgroundColor: UIColor.clear,
        //                                                         .kern: 0.7,
        //                                                         .paragraphStyle: paragraphStyle]
        //
        //        let attributedText = NSAttributedString(string: text ?? "",
        //                                                attributes: attributes)
        //
        //        setAttributedTitle(attributedText, for: .normal)
        
        setTitle(text, for: .normal)
        titleLabel?.font = font
        setTitleColor(color, for: .normal)
        backgroundColor = .clear
        
        if showRightImage == true,
           let titleLabel = titleLabel {
            let imageView = UIImageView(image: UIImage(named: "arrow-right")?.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = color
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 20),
                imageView.widthAnchor.constraint(equalToConstant: 16),
                imageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: -2),
                imageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10)
            ])
        }
        
        titleEdgeInsets.top = 1
    }
    
    func setUnderlineStyle(with text: String) {
        let font = UIFont.getFont(with: .workSans,
                                  style: .light,
                                  size: 16)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: UIColor.mainText,
                                                         .backgroundColor: UIColor.clear,
                                                         .paragraphStyle: paragraphStyle,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        let attributedText = NSMutableAttributedString(string: text,
                                                       attributes: attributes)
        
        setAttributedTitle(attributedText, for: .normal)
    }

    func setGoogleSignInStyle() {
        setSocialNetworkSignInStyle(with: "Sign in with Google", imageName: "google")
    }
    
    func setFacebookSignInStyle() {
        setSocialNetworkSignInStyle(with: "Sign in with Facebook", imageName: "facebook")
    }
    
    func setAppleSignInStyle() {
        setSocialNetworkSignInStyle(with: "Sign in with Apple", imageName: "apple")
    }
    
    private func setSocialNetworkSignInStyle(with title: String, imageName: String) {
        setTitle(title, for: .normal)
        setTitleColor(.mainBg, for: .normal)
        setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        let font = UIFont.getFont(with: .workSans,
                                  style: .medium,
                                  size: 16)
        titleLabel?.font = font
        
        backgroundColor = .mainText
        
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
        roundCornersAndCenterContent()
    }
    
    // MARK: - Private
    
    private func roundCornersAndCenterContent() {
        layer.cornerRadius = 25//bounds.height / 2
        contentVerticalAlignment = .center
        contentHorizontalAlignment = .center
    }
}
