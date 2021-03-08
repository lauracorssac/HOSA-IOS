//
//  RefreshCellViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 7/14/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

struct RefreshCellViewModel {
    
    let refreshButtonPressed = PublishSubject<Void>()
    let title: String
    
}
