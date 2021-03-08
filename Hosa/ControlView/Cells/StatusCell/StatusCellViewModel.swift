//
//  StatusCellViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/26/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class StatusCellViewModel {
    
    let statusDriver: Driver<StatusButtonStyleType>
    
    init(raspberryIsEnable: BehaviorSubject<Bool>) {
        
        statusDriver = raspberryIsEnable
            .map { $0 ? StatusButtonStyleType.on : StatusButtonStyleType.off }
            .asDriver(onErrorJustReturn: .off)
        
    }
    
}
