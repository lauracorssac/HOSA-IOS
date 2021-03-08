//
//  TextTableViewCell.swift
//  Hosa
//
//  Created by Laura Corssac on 10/30/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit

final class TextTableViewCell: UITableViewCell {

    let cellLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubviews([cellLabel])
        cellLabel.numberOfLines = 0
        cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        cellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        cellLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        cellLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.vertical).isActive = true
        
       
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: NSAttributedString) {
        cellLabel.attributedText = text
        cellLabel.font = UIFont.systemFont(ofSize: 17)
    }

}
