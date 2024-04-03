//
//  RadioButtonsGroup.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit

@objc
protocol RadioButtonsGroupDelegate: NSObjectProtocol {
    @objc func didCheckedButton(at index: Int)
}

final class RadioButtonsGroup: UIView {

    private var buttons: [RadioButton] = []
    
    private(set) var selectedIndex: Int?
    
    weak var delegate: RadioButtonsGroupDelegate?
    
    
    // MARK: - Init
    
    init(with titles: [String],
         selectedIndex: Int? = nil,
         delegate: RadioButtonsGroupDelegate? = nil) {
        super.init(frame: .zero)
        
        setup(with: titles, selectedIndex: selectedIndex)
        
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Setup view
    
    func setSelectedValue(at index: Int?) {
        if let index = index {
            for button in buttons {
                button.set(false)
            }
            
            buttons[index].set(true)
        }
    }
    
    private func setup(with titles: [String],
                       selectedIndex: Int? = nil) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        for object in titles.enumerated() {
            let index = object.offset
            let title = object.element
            
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let button = RadioButton(style: .radio, isChecked: index == selectedIndex)
            button.tag = index
            button.addTarget(self,
                             action: #selector(onTapButton(_:)),
                             for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            buttons.append(button)
            view.addSubview(button)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setParagraphStyle(with: .medium, text: title)
            
            view.addSubview(label)
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 25),
                button.widthAnchor.constraint(equalToConstant: 25),
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                label.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 5),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                
                view.heightAnchor.constraint(equalTo: button.heightAnchor),
            ])
            
            stackView.addArrangedSubview(view)            
        }
    }
    
    // MARK: - Button checked
    
    @objc private func onTapButton(_ sender: UIButton) {
        for button in buttons {
            button.set(false)
        }
        
        (sender as? RadioButton)?.set(true)
        
        selectedIndex = sender.tag
        
        delegate?.didCheckedButton(at: sender.tag)
    }
    
}
