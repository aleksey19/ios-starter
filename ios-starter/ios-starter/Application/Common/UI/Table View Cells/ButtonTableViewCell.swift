//
//  ButtonTableViewCell.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 31.03.2024.
//

import UIKit
import RxSwift

class ButtonTableViewCell: UITableViewCell {
    
    typealias Action = (() -> Void)
    
    private var button: UIButton!
    
    private var bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
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
        button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Bind
    
    func bind(title: String,
              actionTrigger: PublishSubject<Void>) {
        button.set(style: .filled, text: title)
        
        button
            .rx
            .tap
            .bind(to: actionTrigger)
            .disposed(by: bag)
    }
}
