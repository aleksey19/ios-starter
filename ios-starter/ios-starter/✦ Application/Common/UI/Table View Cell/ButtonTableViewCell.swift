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
    
    @IBOutlet private weak var button: UIButton!
    
    private var bag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
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
