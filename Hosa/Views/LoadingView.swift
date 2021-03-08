//
//  LoadingView.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/26/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

final class LoadingView: UIView {
    
    let spinner = UIActivityIndicatorView(style: .large)
    
    init() {
        super.init(frame: .zero)
        
        self.addSubviews([spinner])
        spinner.applyDefaultAnchorsToSuperView()
        
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension Reactive where Base: LoadingView {
    
    var isLoading: Binder<Bool> {
        return Binder(self.base) { view, isLoading in
            
            view.isHidden = !isLoading
            
            if isLoading {
                view.spinner.startAnimating()
                
            } else {
                view.spinner.stopAnimating()
            }
     
        }
    }
    
}
