//
//  StatusButton.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/24/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum StatusButtonStyleType: String {
    case on
    case off
}

struct StatusButtonStyle {
    let backgroundColor: UIColor
    let textColor: UIColor
}

class StatusButtonStyleFabric {
    
    static func getStyleFor(type: StatusButtonStyleType) -> StatusButtonStyle {
        switch type {
        case .on:
            return StatusButtonStyle(backgroundColor: Colors.green, textColor: .white)
        case .off:
            return StatusButtonStyle(backgroundColor: Colors.red, textColor: .white)
            
        }
    }
    
}

class StatusView: UIView {

    let statusLabel = UILabel()
    
    init(status: StatusButtonStyleType) {
        super.init(frame: .zero)
        
        self.addSubviews([statusLabel])
        statusLabel.text = status.rawValue
        statusLabel.textAlignment = .center
        self.applyConstraints()
        self.apply(style: StatusButtonStyleFabric.getStyleFor(type: status))
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConstraints() {
        
        self.statusLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        self.statusLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        self.statusLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        self.statusLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
    }
    
    func apply(style: StatusButtonStyle) {
        
        self.statusLabel.textColor = style.textColor
        self.backgroundColor = style.backgroundColor
    }
    
}

extension Reactive where Base: StatusView {
    
    var status: Binder<StatusButtonStyle> {
        return Binder(self.base) { view, value in
            view.apply(style: value)
        }
    }
    
    var text: Binder<String> {
        return Binder(self.base) { view, text in
            view.statusLabel.text = text
        }
    }
    
}
