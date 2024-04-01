//
//  RadioButtonsTableViewCell.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift

class RadioButtonsTableViewCell: UITableViewCell {
    
    typealias ViewModel = InputFieldViewModel & InputFieldRadioButtonViewModelCompatible
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var radioButtonsBgView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!

    private(set) var selectedTag: Int?
    
    private var bag = DisposeBag()
    
    // MARK: - Output
    
    private var selectedTagSubject: BehaviorSubject<Int?> = .init(value: nil)

    // MARK: - prepareForReuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bag = DisposeBag()
        
        selectedTag = nil
    }
    
    // MARK: - Bind view model
    
    func bind(viewModel: ViewModel) {
        titleLabel.setOverlineTextStyle(text: viewModel.name.uppercased(),
                                        color: .lightGray)

        selectedTagSubject
            .filterNil()
            .bind(to: viewModel.input)
            .disposed(by: bag)
        
        // Bind to hide error when select radio button
        selectedTagSubject
            .filterNil()
            .map({ viewModel.titles[$0] })
            .bind(to: viewModel.inputValue)
            .disposed(by: bag)
        
        viewModel
            .validationErrors
            .bind(onNext: { [weak self] error in
                self?.setInputState(errorText: error?.localizedDescription, underlineColor: .error)
            })
            .disposed(by: bag)
        
        selectedTag = viewModel.selectedValueIndex ?? Int(viewModel.value ?? "")
        
        setupRadioButtons(with: viewModel.titles,
                          selectedIndex: selectedTag,
                          isInputAvailable: viewModel.isInputAvailable)
    }
    
    // MARK: - Setup radio buttons
    
    private func setupRadioButtons(with titles: [String],
                                   selectedIndex: Int? = nil,
                                   isInputAvailable: Bool = false) {
        var radioButtonsGroup = radioButtonsBgView.subviews.first(where: { $0 is RadioButtonsGroup }) as? RadioButtonsGroup
        
        defer {
            radioButtonsGroup?
                .rx
                .didCheckedButton
                .bind(to: selectedTagSubject)
                .disposed(by: bag)
        }
        
        guard
            let radioButtonsGroup = radioButtonsGroup
        else {
            let group = RadioButtonsGroup(with: titles, selectedIndex: selectedIndex)
            group.isUserInteractionEnabled = isInputAvailable
            group.translatesAutoresizingMaskIntoConstraints = false

            radioButtonsBgView.addSubview(group)
            
            NSLayoutConstraint.activate([
                group.leadingAnchor.constraint(equalTo: radioButtonsBgView.leadingAnchor),
                group.topAnchor.constraint(equalTo: radioButtonsBgView.topAnchor),
                group.trailingAnchor.constraint(equalTo: radioButtonsBgView.trailingAnchor),
                group.bottomAnchor.constraint(equalTo: radioButtonsBgView.bottomAnchor),
            ])
            
            radioButtonsGroup = group
            
            return
        }
        
        radioButtonsGroup.setSelectedValue(at: selectedIndex)
    }
    
    // MARK: - Private
    
    private func setInputState(errorText: String? = nil, underlineColor: UIColor) {
        errorLabel.setParagraphStyle(with: .caption, text: errorText, color: underlineColor)
        errorLabel.isHidden = errorText == nil
    }
}
