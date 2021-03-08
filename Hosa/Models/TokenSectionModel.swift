//
//  TokenSectionModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/6/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxDataSources

enum TokenSectionModel {
    case tokenSection(title: String, items: [TokenSectionItem])
    case refreshSection(title: String, items: [TokenSectionItem])
    
}

extension TokenSectionModel: SectionModelType {
    typealias Item = TokenSectionItem
    
    var items: [TokenSectionItem] {
        switch  self {
        case .tokenSection(title: _, items: let items):
            return items.map { $0 }
        case .refreshSection(title: _, items: let items):
             return items.map { $0 }
        }
    }
    
    init(original: TokenSectionModel, items: [Item]) {
        switch original {
        case let .tokenSection(title: title, items: _):
            self = .tokenSection(title: title, items: items)
        case .refreshSection(title: let title, items: let items):
            self = .refreshSection(title: title, items: items)
        }
    }
}

enum TokenSectionItem {
    case tokenCell(viewModel: TokenTableViewCellViewModel)
    case refresh(viewModel: RefreshCellViewModel)
}
