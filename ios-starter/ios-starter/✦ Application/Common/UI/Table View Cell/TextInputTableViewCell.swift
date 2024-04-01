//
//  TextInputTableViewCell.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift

class TextInputTableViewCell: UITableViewCell {

    private(set) var inputValueView: InputView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        inputValueView.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        inputValueView = InputView.loadFromNIB()
        inputValueView.backgroundColor = .clear
        inputValueView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(inputValueView)
        
        NSLayoutConstraint.activate([
            inputValueView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            inputValueView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            inputValueView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            inputValueView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
        ])
    }
    
    func bind(viewModel: InputFieldViewModel,
              showLeftView: Bool = false,
              toolBar: UIToolbar? = nil) {
        inputValueView.bindViewModel(viewModel,
                                     showLeftView: showLeftView,
                                     toolBar: toolBar)
    }
    
    func bind(viewModel: InputFieldViewModel & InputFieldPickerViewModelCompatible,
              picker: UIPickerView,
              toolBar: UIToolbar) {
        inputValueView.bindViewModel(viewModel,
                                pickerView: picker,
                                toolBar: toolBar,
                                showRightArrowView: true)
    }
    
    func bindViewModel(_ viewModel: InputFieldViewModel, showDropDownTrigger: PublishSubject<Void>) {
        inputValueView.bindViewModel(viewModel, showDropDownTrigger: showDropDownTrigger)
    }
    
}
