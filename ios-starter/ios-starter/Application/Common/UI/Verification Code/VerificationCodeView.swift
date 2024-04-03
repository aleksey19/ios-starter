//
//  VerificationCodeView.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift

class VerificationCodeView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }
    @IBOutlet weak var textFieldsStackView: UIStackView!
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.text = nil
        }
    }
    
    private var textFields: [VerificationCodeDigitTextField] = []
    private let bag = DisposeBag()
        
    func bindViewModel(_ viewModel: VerificationCodeViewModel) {
        
        
        for _ in 0..<viewModel.codeLength {
            let textField = VerificationCodeDigitTextField()
            textField.borderStyle = .none
            textField.addUnderline(with: .lightGray)
            textField.delegate = self
            textField.keyboardType = .numberPad
            textField.setStyle(with: nil,
                               placeholder: nil,
                               textColor: .mainText,
                               placeholderColor: .placeholder,
                               textAlignment: .center)
                        
            // Jump to previous text field if backward was pressed and text is empty
            textField.deleteKeyPressedIfEmptyText = { [weak self] textField in
                _ = self?.textField(textField,
                                    shouldChangeCharactersIn: NSRangeFromString(""),
                                    replacementString: "")
            }

            textFields.append(textField)
            textFieldsStackView.addArrangedSubview(textField)
        }
        
        viewModel
            .validationError
            .skip(1)
            .bind(onNext: { [weak self] error in
                self?.errorLabel.setParagraphStyle(with: .caption, text: error?.localizedDescription, color: .error)
                self?.errorLabel.isHidden = error == nil
                self?.setUnderline(with: error == nil ? .white : .systemRed)
            })
            .disposed(by: bag)
        
        Observable
            .combineLatest(textFields.map({ $0.rx.text }))
            .distinctUntilChanged()
            .compactMap { values -> String in
                let retValue = values.compactMap({ $0 }).reduce("", +)
                return retValue
            }
            .bind(to: viewModel.input)
            .disposed(by: bag)
        
        setupEditingMode()
    }
    
    private func setUnderline(with color: UIColor) {
        for textField in textFields {
            textField.addUnderline(with: color)
        }
    }
    
    private func setupEditingMode() {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: textFieldsStackView.leadingAnchor),
            button.topAnchor.constraint(equalTo: textFieldsStackView.topAnchor),
            button.trailingAnchor.constraint(equalTo: textFieldsStackView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: textFieldsStackView.bottomAnchor)
        ])
        
        button
            .rx
            .tap
            .bind(onNext: { [weak self] in
                let code = self?.textFields.map({ $0.text ?? "" }).compactMap({ $0 }).reduce("", +) ?? ""
                let isEmptyCode = code.count == 0
                let targetTextField = isEmptyCode == true ? self?.textFields.first : self?.textFields.last
                targetTextField?.becomeFirstResponder()
            })
            .disposed(by: bag)
    }
}

extension UITextField {
    func addUnderline(with color: UIColor) {
        let underlineTag = 1
        
        if let underlineView = self.subviews.first(where: { $0.tag == underlineTag }) {
            underlineView.backgroundColor = color
            return
        }
        
        let view = UIView(frame: .zero)
        view.tag = underlineTag
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 2),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}

extension VerificationCodeView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        var textFieldIndex = 0
        let textFieldsCount = textFields.count

        textFields.enumerated().forEach { e in
            if textField == e.element {
                textFieldIndex = e.offset
            }
        }

        if string.count == 1 {
            textField.text = string
            
            if textFieldIndex == textFieldsCount - 1 {
                textField.resignFirstResponder()
            } else {
                textFields[textFieldIndex + 1].becomeFirstResponder()
            }

            return false
        } else if string.count == 0 {
            if textField.text?.count ?? 0 > 0 {
                return true
            }
            
            if textFieldIndex == 0 {
                textField.resignFirstResponder()
            } else {
                // Activate previous text field and clear it
                textFields[textFieldIndex - 1].becomeFirstResponder()
                textFields[textFieldIndex - 1].deleteBackward()
                return false
            }

            return false
        }

        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.isHidden = true
        errorLabel.text = nil
        setUnderline(with: .white)
    }
}
