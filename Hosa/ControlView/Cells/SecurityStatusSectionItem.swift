//
//  SecurityStatusSectionItem.swift
//  MQTTTest
//
//  Created by Laura Corssac on 5/22/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

enum SecurityStatusSectionItem {
    
    case statusControl(viewModel: ControlCellViewModel)
    case status(viewModel: StatusCellViewModel)
    case refresh(viewModel: RefreshCellViewModel)
}

