//
//  LineView.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/6/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UIKit

final class LineView: UIView {
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .lightGray
        self.layer.opacity = 0.5
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyConstraints() {
        
        guard let superView = self.superview else {
            return
        }
        self.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
    }
}
