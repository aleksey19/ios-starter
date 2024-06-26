//
//  StateAndZipTableViewCell.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift

class StateAndZipTableViewCell: UITableViewCell {
    
    private var inputStateValueView: InputView!
    private var inputZipValueView: InputView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        inputStateValueView.prepareForReuse()
        inputZipValueView.prepareForReuse()
    }
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        initControls()
    }
    
    private func initControls() {
        inputStateValueView = InputView.loadFromNIB()
        inputStateValueView.backgroundColor = .clear
        inputStateValueView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(inputStateValueView)
        
        inputZipValueView = InputView.loadFromNIB()
        inputZipValueView.backgroundColor = .clear
        inputZipValueView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(inputZipValueView)
        
        NSLayoutConstraint.activate([
            inputStateValueView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            inputStateValueView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            inputStateValueView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            inputZipValueView.leadingAnchor.constraint(equalTo: inputStateValueView.trailingAnchor, constant: 16),
            inputZipValueView.topAnchor.constraint(equalTo: inputStateValueView.topAnchor),
            inputZipValueView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            inputZipValueView.bottomAnchor.constraint(equalTo: inputStateValueView.bottomAnchor),
            
            inputStateValueView.widthAnchor.constraint(equalTo: inputZipValueView.widthAnchor)
        ])
    }
    
    // MARK: - Bind
    
    func bind(stateViewModel: SignUpStateFieldViewModel,
              showStateDropDownTrigger: PublishSubject<Void>,
              zipViewModel: InputFieldViewModel) {
        inputStateValueView.bindViewModel(stateViewModel, showDropDownTrigger: showStateDropDownTrigger)
        inputZipValueView.bindViewModel(zipViewModel)
    }
}
