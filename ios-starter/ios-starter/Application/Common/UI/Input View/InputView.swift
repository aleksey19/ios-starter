//
//  InputView.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class InputView: UIView {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var underlineView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var checkSecureTextButton: UIButton!
    private var customDropDownButton: UIButton?
    
    private var bag = DisposeBag()
    private var isPhoneNumberInput: Bool = false
    
    var textInput: Observable<String> {
        textField.rx.text.filterNil()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setInitialState()
    }

    func prepareForReuse() {
        bag = DisposeBag()
        setInitialState()
    }

    // MARK: - Bind view model
    
    func bindViewModel(_ viewModel: InputFieldViewModel,
                       showLeftView: Bool = false,
                       toolBar: UIToolbar? = nil) {
        nameLabel.setOverlineTextStyle(text: viewModel.name.uppercased(),
                                       color: .secondaryText)
        
        textField.inputView = nil
        textField.inputAccessoryView = toolBar
        
        textField.setStyle(with: viewModel.value,
                           placeholder: viewModel.placeholder,
                           textColor: viewModel.isInputAvailable ? .mainText : .placeholder,
                           placeholderColor: .placeholder,
                           shouldSetDefaultTextAttributes: viewModel.isSecureTextEntry == true ? false : true)
        
        if let error = viewModel.error {
            setInputState(errorText: error.localizedDescription, underlineColor: .error)
        } else {
            var color: UIColor = (viewModel.value?.count ?? 0) > 0 ? .mainText : .lightGray
            color = viewModel.isInputAvailable ? color : .placeholder
            setInputState(underlineColor: color)
        }
        
        textField.keyboardType = viewModel.keyboardType
        textField.isSecureTextEntry = viewModel.isSecureTextEntry
        textField.autocorrectionType = viewModel.autocorrection ? .yes : .no
        textField.isUserInteractionEnabled = viewModel.isInputAvailable

        textField
            .rx
            .text
            .filterNil()
            .skip(1)
            .map({ [weak self] string in
                if self?.isPhoneNumberInput == true {
                    let string = string.withMask(mask: "")
                    
                    var mask = String.phoneNumberMask

                    if string.contains("+1") == true {
                        mask = String.phoneNumberInternationalMask
                    }
                    
                    let formattedText = string.withMask(mask: mask)
                    self?.textField.text = formattedText
                    
                    return formattedText
                } else if let mask = viewModel.inputMask {
                    let string = string.withMask(mask: "")
                    
                    let formattedText = string.withMask(mask: mask)
                    self?.textField.text = formattedText
                    
                    return formattedText
                }
                
                return string
            })
            .bind(to: viewModel.inputValue)
            .disposed(by: bag)

        viewModel
            .validationErrors
            .skip(1)
            .bind(onNext: { [weak self] error in
                var color: UIColor = self?.textField.isEditing == true ? .accent : .mainText
                color = error?.localizedDescription == nil ? color : .error
                color = (self?.textField.text?.count == 0 && error == nil) ? .lightGray : color
                self?.setInputState(errorText: error?.localizedDescription, underlineColor: color)
            })
            .disposed(by: bag)
        
        textField
            .rx
            .isFirstResponder
            .filter({ $0 == true })
            .bind(onNext: { [weak self] _ in
                self?.setInputState(errorText: nil, underlineColor: .accent)
            })
            .disposed(by: bag)
        
        if showLeftView {
            textField.setInputMoneyStyle()
        }
        
        checkSecureTextButton.isHidden = !viewModel.isSecureTextEntry
        
        if viewModel.isSecureTextEntry {
            let longTapGesture = UILongPressGestureRecognizer()
            longTapGesture.minimumPressDuration = .init(0.2)
            
            checkSecureTextButton.addGestureRecognizer(longTapGesture)
            checkSecureTextButton.isUserInteractionEnabled = true                        
            
            longTapGesture
                .rx
                .event
                .bind(onNext: { [weak self] gr in
                    switch gr.state {
                    case .began:
                        self?.textField.isSecureTextEntry = false
                        self?.checkSecureTextButton.isSelected = true
                    case .ended:
                        self?.textField.isSecureTextEntry = true
                        self?.checkSecureTextButton.isSelected = false
                    default:
                        break
                    }
                })
                .disposed(by: bag)
        }

        isPhoneNumberInput = viewModel.keyboardType == .phonePad
    }
    
    func bindViewModel(_ viewModel: InputFieldViewModel & InputFieldPickerViewModelCompatible,
                       pickerView: UIPickerView,
                       toolBar: UIToolbar,
                       showLeftView: Bool = false,
                       showRightArrowView: Bool = false) {
        bindViewModel(viewModel, showLeftView: showLeftView)
        
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
        
        if showRightArrowView {
            textField.showRightArrow()
        }
        
        viewModel
            .valuesObservable
            .bind(to: pickerView.rx.itemTitles) { $1 }
            .disposed(by: bag)
        
        Observable
            .combineLatest(viewModel.valuesObservable,
                           pickerView.rx.itemSelected) { [weak self] (states, tuple) in
                let idx = tuple.row
                let state = states[idx]
                self?.textField.text = state
                
                return state
            }
            .bind(to: viewModel.inputValue)
            .disposed(by: bag)
    }
    
    /// Bind custom drop down input view
    func bindViewModel(_ viewModel: InputFieldViewModel, showDropDownTrigger: PublishSubject<Void>) {
        bindViewModel(viewModel, showLeftView: false)
        
        // If no error underline with main text color
        viewModel
            .validationErrors
            .skip(1)
            .bind(onNext: { [weak self] error in
                var color: UIColor = error?.localizedDescription == nil ? .mainText : .error
                color = (self?.textField.text?.isEmpty == true && error == nil) ? .divider : color
                self?.setInputState(errorText: error?.localizedDescription, underlineColor: color)
            })
            .disposed(by: bag)
        
        textField.inputView = UIView()
        textField.inputAccessoryView = UIView()
        textField.showRightArrow()
        // Set clear color to hide cursor
        textField.tintColor = .clear
        
        textField.setStyle(with: viewModel.value,
                           placeholder: viewModel.placeholder,
                           textColor: viewModel.isInputAvailable ? .mainText : .placeholder,
                           placeholderColor: .placeholder)
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            button.topAnchor.constraint(equalTo: textField.topAnchor),
            button.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
        ])
        
        button
            .rx
            .tap
            .do(onNext: { [weak self] in
                self?.textField.becomeFirstResponder()
                self?.setInputState(errorText: nil, underlineColor: .accent)
            })
            .bind(to: showDropDownTrigger)
            .disposed(by: bag)
        
        self.bringSubviewToFront(button)
        self.customDropDownButton = button

        viewModel
            .inputValue
            .filterEmpty()
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in
                self?.setInputState(errorText: nil, underlineColor: .mainText)
                self?.textField.resignFirstResponder()
                self?.textField.endEditing(true)
            })
            .bind(to: textField.rx.text)
            .disposed(by: bag)
    }
    
    // MARK: - Private
    
    private func listenTextFieldEvents() {
        textField
            .rx
            .controlEvent(.editingDidBegin)
            .bind { [weak self] _ in
                self?.setInputState(underlineColor: .accent)
            }
            .disposed(by: bag)                
    }
    
    private func setInputState(errorText: String? = nil, underlineColor: UIColor) {
        errorLabel.setParagraphStyle(with: .caption, text: errorText, color: underlineColor)
        errorLabel.isHidden = errorText == nil
        
//        textField.layer.borderColor = underlineColor.cgColor
        underlineView.backgroundColor = underlineColor
    }
    
    private func setInitialState() {
        setInputState(errorText: nil, underlineColor: .mainText)
        
        textField.setStyle(with: nil,
                           placeholder: nil,
                           textColor: .mainText,
                           placeholderColor: .divider,
                           shouldSetDefaultTextAttributes: false)
        
        textField.keyboardType = .default
        textField.isSecureTextEntry = false
        textField.autocorrectionType = .no
        textField.leftView = nil
        textField.rightView = nil
        textField.inputView = nil
        textField.inputAccessoryView = nil
        textField.tintColor = .white
        
        checkSecureTextButton.imageView?.tintColor = .placeholder
        checkSecureTextButton.setImage(UIImage(named: "eye-on")?.withRenderingMode(.alwaysTemplate), for: .normal)
        checkSecureTextButton.setImage(UIImage(named: "eye-off")?.withRenderingMode(.alwaysTemplate), for: .selected)
        
        listenTextFieldEvents()
        
        // Remove button from custom drop down
        customDropDownButton?.removeFromSuperview()
        customDropDownButton = nil
    }
}
