//
//  StatusTableViewCell.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/24/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxSwift

final class StatusTableViewCell: UITableViewCell {
    
    private let statusView = StatusView(status: .off)
    private var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        let titleLabel = UILabel()
        titleLabel.text = "Raspberry Status"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0
        
        self.contentView.addSubviews([statusView, titleLabel])
        
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        statusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        statusView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        statusView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        statusView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.vertical).isActive = true
        statusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.vertical).isActive = true
        statusView.widthAnchor.constraint(equalToConstant: 72).isActive = true
        
    }
    
    func configure(viewModel: StatusCellViewModel) {
        
        viewModel.statusDriver
            .map { StatusButtonStyleFabric.getStyleFor(type: $0) }
            .drive(statusView.rx.status)
            .disposed(by: disposeBag)
        
         viewModel.statusDriver
            .map {$0.rawValue}
            .drive(statusView.rx.text)
            .disposed(by: disposeBag)
    }
    
}

