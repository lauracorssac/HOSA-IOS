//
//  LoadableButton.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/28/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum LoadableButtonStyleType: String {
    case green
}

struct LoadableButtonStyle {
    let backgroundColor: UIColor
}

class LoadableButtonStyleFabric {
    
    static func getStyleFor(type: LoadableButtonStyleType) -> LoadableButtonStyle {
        switch type {
        case .green:
            return LoadableButtonStyle(backgroundColor: Colors.green)
        
        }
    }
}

class LoadableButton: UIButton {
    
    let originalButtonTitle: String
    let spinner = UIActivityIndicatorView(style: .medium)
    var originalBackgroundColor = UIColor.gray
    
    init(title: String = "") {
        
        originalButtonTitle = title
        super.init(frame: .zero)
        self.showsTouchWhenHighlighted = true

        self.addSubviews([spinner])
        spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.spinner.isHidden = true
        self.setTitle(originalButtonTitle, for: .normal)
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyStye(style: LoadableButtonStyle) {
        self.originalBackgroundColor = style.backgroundColor
        self.backgroundColor = style.backgroundColor
    }
    
}

extension Reactive where Base: LoadableButton {
    
    var isLoading: Binder<Bool> {
        return Binder(self.base) { view, isLoading in
            
            if isLoading {
                view.spinner.isHidden = false
                view.spinner.startAnimating()
                view.setTitle("", for: .normal)
            } else {
                
                view.spinner.isHidden = true
                view.spinner.stopAnimating()
                view.setTitle(view.originalButtonTitle, for: .normal)
            }
            
        }
    }
    
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { view, isEnabled in
            
            if isEnabled {
                
                view.isEnabled = true
                view.backgroundColor = view.originalBackgroundColor
            } else {
                
                view.backgroundColor = .lightGray
                view.isEnabled = false
            }
            
        }
    }
}
