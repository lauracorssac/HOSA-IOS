//
//  ControlTableViewCell.swift
//  MQTTTest
//
//  Created by Laura Corssac on 5/22/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ControlTableViewCell: UITableViewCell {
    
    static let identifier = "\(ControlTableViewCell.self)"
    private var disposeBag = DisposeBag()
    
    private let descriptionLabel = UILabel()
    private let controlTitleLabel = UILabel()
    private let controlSwitch = UISwitch()
    private let loadingView = LoadingView()
    private let lineView = LineView()
    
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
    
    func setup() {
        
        controlTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        self.contentView.addSubviews([descriptionLabel, controlTitleLabel, controlSwitch, loadingView, lineView])
        
        controlSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        controlSwitch.centerYAnchor.constraint(equalTo: controlTitleLabel.centerYAnchor).isActive = true
        
        controlTitleLabel.trailingAnchor.constraint(equalTo: controlSwitch.trailingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        controlTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.vertical).isActive = true
        controlTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: controlTitleLabel.bottomAnchor, constant: Spacing.vertical).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: lineView.topAnchor, constant: -Spacing.vertical).isActive = true
        
        loadingView.centerYAnchor.constraint(equalTo: controlSwitch.centerYAnchor).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: controlSwitch.centerXAnchor).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        
        lineView.applyConstraints()
      
        
    }
    
    func configure(viewModel: ControlCellViewModel) {
        
        controlSwitch.onTintColor = Colors.green
        
        viewModel.title
            .drive(controlTitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.switchStateDriver
            .map { $0 == .on }
            .drive(self.controlSwitch.rx.isOn)
            .disposed(by: disposeBag)
        
        viewModel.switchStateDriver
            .map { $0 == .loading }
            .drive(self.loadingView.rx.isLoading)
            .disposed(by: disposeBag)
        
        viewModel.switchStateDriver
            .map { $0 == .loading }
            .drive(self.controlSwitch.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.descriptionDriver
            .drive(self.descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .controlShouldBeEnabled
            .bind(to: self.controlSwitch.rx.isEnabled)
            .disposed(by: disposeBag)
        
        controlSwitch.rx
            .controlEvent(.valueChanged)
            .withLatestFrom(controlSwitch.rx.value)
            .bind(to: viewModel.userSwitched)
            .disposed(by: disposeBag)
        
    }
    
}
