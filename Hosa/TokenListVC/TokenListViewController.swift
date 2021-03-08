//
//  TokenGenerationViewController.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/10/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxCocoa
import RxDataSources
import RxSwift

final class TokenListViewController: ViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: TokenListViewModel
    
    init(viewModel: TokenListViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingView = LoadingView()
        let tokenGenerationView = TokenGenerationView(viewModel: self.viewModel.subViewModel)
        let errorView = ErrorView(descriptionText: "Not possible to load tokens")
        let tokenTableView = UITableView()
        
        self.view.addSubviews([tokenTableView, loadingView, tokenGenerationView, errorView])
        
        tokenTableView.register(RefreshTableViewCell.self, forCellReuseIdentifier: "\(RefreshTableViewCell.self)")
        tokenTableView.register(TokenTableViewCell.self, forCellReuseIdentifier: "\(TokenTableViewCell.self)")
        loadingView.applyAnchorsToSuperView()
        errorView.applyAnchorsToSuperView()
        tokenGenerationView.applyAnchorsToSuperView()
        
        tokenTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tokenTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tokenTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tokenTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        tokenTableView.estimatedRowHeight = 44 + Spacing.vertical * 2
        tokenTableView.separatorStyle = .none
        
        viewModel
            .viewStateDriver
            .map { $0 != .loading }
            .drive( loadingView.rx.isHidden)
            .disposed(by: disposeBag)
            
        viewModel
           .viewStateDriver
           .map { $0 != .error}
           .drive( errorView.rx.isHidden)
           .disposed(by: disposeBag)
        
        viewModel
            .viewStateDriver
            .map { $0 != .empty }
            .drive( tokenGenerationView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel
            .viewStateDriver
            .map { $0 != .success }
            .drive( tokenTableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        tokenGenerationView
            .getTokenButton
            .rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .bind(to: viewModel.tokenButtonPressed)
            .disposed(by: disposeBag)
        
        errorView
            .reloadButton
            .rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .bind(to: viewModel.tryAgainButtonPressed)
            .disposed(by: disposeBag)
        
        let dataSource = TokenListViewController.dataSource()
        
        viewModel.sectionList
            .bind(to: tokenTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tokenTableView.rx.itemDeleted
            .filter { $0.count == 2 }
            .map { $0[1] }
            .bind(to: viewModel.deletedRow)
            .disposed(by: disposeBag)
        
        viewModel.shouldDisplayErrorAlertDriver
            .filter { $0 != nil }
            .drive { [weak self] error in
                self?.presentErrorAlert(error: error as NSError?)
            }.disposed(by: disposeBag)
        
        
        tokenTableView.rx
            .modelSelected(TokenSectionItem.self)
            .map { item -> TokenTableViewCellViewModel? in
                switch item {
                case let .tokenCell(vm):
                    return vm
                case .refresh(viewModel: _):
                    return nil
                }
            }
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: viewModel.modelSelected)
            .disposed(by: disposeBag)
        
    }
 
}

extension TokenListViewController {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<TokenSectionModel> {
        return RxTableViewSectionedReloadDataSource<TokenSectionModel>(configureCell: { dataSource, table, indexPath, item in
            switch item {
            case let .tokenCell(viewModel: viewModel):
                guard let cell = table.dequeueReusableCell(withIdentifier: "\(TokenTableViewCell.self)") as? TokenTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(with: viewModel)
                return cell
                
            case let .refresh(viewModel: viewModel):
                guard let cell = table.dequeueReusableCell(withIdentifier: "\(RefreshTableViewCell.self)") as? RefreshTableViewCell else { return UITableViewCell() }
                cell.configure(viewModel: viewModel)
                return cell
            }
        },canEditRowAtIndexPath: { aa, indexPath in
            return indexPath[0] == 0
        })
    }
    
}
