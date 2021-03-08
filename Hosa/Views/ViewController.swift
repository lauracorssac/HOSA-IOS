//
//  ViewController.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/6/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    
    lazy var viewBackgroundColor: BehaviorSubject<UIColor> = {
        return BehaviorSubject<UIColor>(value: self.getColor(for: self.traitCollection))
    }()
    
    private let disposeBag = DisposeBag()
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewBackgroundColor
            .bind(to: self.view.rx.backgroundColor)
            .disposed(by: disposeBag)
        
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            self.viewBackgroundColor.onNext(self.getColor(for: self.traitCollection))
        }
    }
    
    func getColor(for traitCollection: UITraitCollection) -> UIColor {
        if traitCollection.userInterfaceStyle == .light {
            return .white
        } else {
            return .black
        }
    }
    
}

