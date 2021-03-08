//
//  TokenInformationViewController.swift
//  Hosa
//
//  Created by Laura Corssac on 10/27/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

enum TokenInformationSectionModel {
    case section(title: String, items: [TokenInformationSectionItem])
}

extension TokenInformationSectionModel: SectionModelType {
    typealias Item = TokenInformationSectionItem
    
    var items: [TokenInformationSectionItem] {
        switch  self {
        case .section(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: TokenInformationSectionModel, items: [Item]) {
        switch original {
        
        case .section(title: let title, items: let items):
            self = .section(title: title, items: items)
        }
    }
}

enum TokenInformationSectionItem {
    case textCell(viewModel: NSAttributedString)
    case imageCell(image: UIImage?)
}

final class TokenInformationViewController: ViewController {
    
    let viewModel: InformationViewModel
    let disposeBag = DisposeBag()
    
    init(viewModel: InformationViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView()
        
        self.view.addSubviews([tableView])
        
        tableView.applyAnchorsToSuperView()
        
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "\(ImageTableViewCell.self)")
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: "\(TextTableViewCell.self)")
        
        let dataSource = TokenInformationViewController.dataSource()
        
        viewModel.sectionList
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }

}

extension TokenInformationViewController {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<TokenInformationSectionModel> {
        return RxTableViewSectionedReloadDataSource<TokenInformationSectionModel>(configureCell: { dataSource, table, indexPath, item in
            switch item {
            case .textCell(viewModel: let text):
                guard let cell = table.dequeueReusableCell(withIdentifier: "\(TextTableViewCell.self)") as? TextTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(text: text)
                return cell
                
            case .imageCell(image: let image):
                guard let cell = table.dequeueReusableCell(withIdentifier: "\(ImageTableViewCell.self)") as? ImageTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(image: image)
                return cell
            }
        })
    }
    
}
