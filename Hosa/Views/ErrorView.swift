//
//  ErrorView.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/28/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ErrorView: UIView {
    
    let reloadButton = UIButton()
    
    init(descriptionText: String) {
        
        super.init(frame: .zero)
        
        let errorLabel = UILabel()
        errorLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        errorLabel.textAlignment = .center
        errorLabel.text = descriptionText
        
        reloadButton.setTitle("Reload", for: .normal)
        reloadButton.setTitleColor(.black, for: .normal)
        reloadButton.backgroundColor = Colors.green
        
        self.addSubviews([reloadButton, errorLabel])
        
        errorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -Spacing.leadingAndTrailing / 2).isActive = true
        
        reloadButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        reloadButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        reloadButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: Spacing.leadingAndTrailing / 2).isActive = true
        reloadButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
