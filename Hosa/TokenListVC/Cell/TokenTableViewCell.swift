//
//  TokenTableViewCell.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/13/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

final class TokenTableViewCell: UITableViewCell {

    private var disposeBag = DisposeBag()
    private let descriptionLabel = UILabel()
    private let titleLabel = UILabel()
    private let loadingView = LoadingView()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {

        let lineView = LineView()
        
        descriptionLabel.numberOfLines = 3
        loadingView.layer.zPosition = 2
        loadingView.backgroundColor = Colors.lightGreen
        loadingView.layer.opacity = 0.5
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        descriptionLabel.font = UIFont.systemFont(ofSize: 17)
        
        contentView.addSubviews([descriptionLabel, loadingView, lineView, titleLabel])
        
        loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.vertical).isActive = true
        
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: lineView.topAnchor, constant: -Spacing.vertical).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.vertical).isActive = true
        
        lineView.applyConstraints()

    }
    
    func configure(with viewModel: TokenTableViewCellViewModel) {
        
        viewModel.descriptionText
            .drive(descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.titleText
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .viewStateDriver
            .map { $0 == .loading }
            .drive(loadingView.rx.isLoading)
            .disposed(by: disposeBag)
    }

}
