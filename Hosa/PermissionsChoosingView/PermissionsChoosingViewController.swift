//
//  PermissionsChoosingViewController.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/17/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PermissionsChoosingViewController: ViewController {
    
    private var disposeBag = DisposeBag()
    private let viewModel: PermissionsChoosingViewModel

    init(viewModel: PermissionsChoosingViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil)
        self.navigationItem.setRightBarButton(closeItem, animated: false)
        
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let confirmButton = LoadableButton(title: "Generate New Token")
        confirmButton.applyStye(style: LoadableButtonStyleFabric.getStyleFor(type: .green))
        
        self.view.addSubviews([tableView, confirmButton])
        
        confirmButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -Spacing.vertical).isActive = true
        
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -Spacing.vertical).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        tableView.register(PermissionOptionTableViewCell.self, forCellReuseIdentifier: "\(PermissionOptionTableViewCell.self)")
        
        closeItem.rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .bind(to: viewModel.closeButtonPressed)
            .disposed(by: disposeBag)
        
        viewModel
            .viewModelsDriver
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "\(PermissionOptionTableViewCell.self)", cellType: PermissionOptionTableViewCell.self)) { [weak self] row, model, cell in
                guard let self = self else { return }
                cell.configure(with: model, backgroundColorSubject: self.viewBackgroundColor)
            }.disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(PermissionOptionCellViewModel.self)
            .subscribe(onNext: { model in
                model.modelSelected.onNext(())
            }).disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .bind(to: viewModel.continueButtonPressed)
            .disposed(by: disposeBag)
        
        viewModel.isLoadingDriver
            .drive(confirmButton.rx.isLoading)
            .disposed(by: disposeBag)
        
        viewModel.errorDriver
            .drive(self.rx.shouldPresentError)
            .disposed(by: disposeBag)
        
        viewModel
            .continueButtonShouldBeEnabledDriver
            .drive(confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.disposeBag = DisposeBag()
    }
}

extension PermissionsChoosingViewController: UITableViewDelegate { }
