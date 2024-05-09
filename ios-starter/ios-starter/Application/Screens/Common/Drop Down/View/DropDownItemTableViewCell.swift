//
//  DropDownItemTableViewCell.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit

class DropDownItemTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var indicatorImageView: UIImageView! {
        didSet {
            indicatorImageView.tintColor = .accent
            indicatorImageView.image = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate)
        }
    }       
    
    func bind(with title: String, selected: Bool = false) {
        nameLabel.setParagraphStyle(with: .regular, text: title)
        
        indicatorImageView.isHidden = !selected
    }
}
