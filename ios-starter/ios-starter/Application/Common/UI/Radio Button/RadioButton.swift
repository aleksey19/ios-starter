//
//  RadioButton.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

class RadioButton: UIButton {
    
    enum Style {
        case radio
        case checkmark
    }
    
    private(set) var isChecked: Bool = false {
        didSet {
            setupStyle()
        }
    }
    private let style: Style
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupStyle()
    }
    
    // MARK: - Init
    
    init(style: Style,
         isChecked: Bool = false) {
        self.style = style
        self.isChecked = isChecked

        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        self.style = .checkmark
        self.isChecked = false

        super.init(coder: coder)
    }
    
    // MARK: - Setup
    
    private func setupStyle() {
        setTitle(nil, for: .normal)
        
        switch self.style {
        case .checkmark:
            let imageName = isChecked == true ? "check" : ""
            setImage(UIImage(named: imageName), for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.mainText.cgColor
            
        case .radio:
            backgroundColor = isChecked ? .mainBg : .mainText
            layer.cornerRadius = frame.width / 2
            layer.borderWidth = 2
            layer.borderColor = UIColor.mainText.cgColor
        }
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        isChecked = !isChecked
    }
    
    func set(_ isChecked: Bool) {
        self.isChecked = isChecked
    }
}
