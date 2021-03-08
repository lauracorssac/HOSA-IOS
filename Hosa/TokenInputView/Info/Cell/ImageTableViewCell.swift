//
//  ImageTableViewCell.swift
//  Hosa
//
//  Created by Laura Corssac on 10/30/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit

final class ImageTableViewCell: UITableViewCell {

    private let cellImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubviews([cellImageView])
        cellImageView.applyAnchorsToSuperView()
        
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: UIImage?) {
        
        guard let image = image else {
            return
        }
        
        cellImageView.image = image
        let multiplier = image.size.height / image.size.width
        cellImageView.heightAnchor.constraint(equalTo: cellImageView.widthAnchor, multiplier: multiplier ).isActive = true
        
    }
}
