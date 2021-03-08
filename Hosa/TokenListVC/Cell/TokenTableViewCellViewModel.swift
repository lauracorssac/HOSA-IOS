//
//  TokenTableViewCellViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 9/2/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokenTableViewCellViewModel {
    
    let titleText: Driver<String>
    let descriptionText: Driver<String>
    let viewStateDriver: Driver<ViewState>
    
    var disposeBag = DisposeBag()
    let state = BehaviorSubject<ViewState>(value: .loaded)
    
    let token: HosaToken
    
    init(token: HosaToken) {
        
        self.token = token
        self.descriptionText = Driver<String>.of(token.encodedValue)
        self.titleText = Driver<String>.of(token.date)
        
        self.viewStateDriver = state.asDriver(onErrorJustReturn: .loaded)
        
    }
    
}
