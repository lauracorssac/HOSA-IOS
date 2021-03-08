//
//  PermissionOptionCellViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/17/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PermissionOptionCellViewModel {
    
    private let isSelected: BehaviorSubject<Bool>
    private let disposeBag = DisposeBag()
   
    let title: Driver<String>
    let isSelectedDriver: Driver<Bool>
    let modelSelected = PublishSubject<Void>()
    
    init(title: Observable<String>, isSelected: BehaviorSubject<Bool>) {
        
        self.isSelected = isSelected
        self.title = title.asDriver(onErrorJustReturn: "")
        self.isSelectedDriver = isSelected.asDriver(onErrorJustReturn: false)
        
        modelSelected
            .withLatestFrom(isSelected)
            .map {
                var value = $0
                value.toggle()
                return value
                
            }.bind(to: isSelected)
            .disposed(by: disposeBag)
    }
    
}
