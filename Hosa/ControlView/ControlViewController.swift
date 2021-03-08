//
//  ControlViewController.swift
//  MQTTTest
//
//  Created by Laura Corssac on 5/18/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ControlViewController: ViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: ControlViewModel
    
    init(viewModel: ControlViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        tableView.register(StatusTableViewCell.self, forCellReuseIdentifier: "\(StatusTableViewCell.self)")
        tableView.register(RefreshTableViewCell.self, forCellReuseIdentifier: "\(RefreshTableViewCell.self)")
        tableView.register(ControlTableViewCell.self, forCellReuseIdentifier: "\(ControlTableViewCell.self)")
        
        tableView.applyAnchorsToSuperView()
        
    }
    
}

extension ControlViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemType = viewModel.dataSource[indexPath.row]
        
        switch itemType {
        case let .statusControl(viewModel: viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ControlTableViewCell.identifier, for: indexPath) as? ControlTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(viewModel: viewModel)
            viewModel.shouldPresentErrorDriver
                .filter { $0 != nil }
                .drive(onNext: { [weak self] _ in
                    self?.presentErrorAlert()
                }).disposed(by: disposeBag)
            return cell
           
        case let .status(viewModel: viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(StatusTableViewCell.self)", for: indexPath) as? StatusTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(viewModel: viewModel)
            return cell
        case let .refresh(viewModel: viewModel):
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(RefreshTableViewCell.self)", for: indexPath) as? RefreshTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(viewModel: viewModel)
            
            return cell
        }
        
    }
    
}
