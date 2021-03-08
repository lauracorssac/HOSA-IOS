//
//  PermissionOptionTableViewCell.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/17/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import RxSwift
import UIKit

final class PermissionOptionTableViewCell: UITableViewCell {

    let permissionLabel = UILabel()
    let isSelectedSubject = BehaviorSubject<Bool>(value: false)
    private var disposeBag = DisposeBag()
    private let checkImageView = UIImageView()
    
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
        
        self.selectionStyle = .none
        checkImageView.tintColor = Colors.green
        
        self.contentView.addSubviews([checkImageView, permissionLabel, lineView])
        
        checkImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        checkImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        
        permissionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        permissionLabel.centerYAnchor.constraint(equalTo: checkImageView.centerYAnchor).isActive = true
        permissionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        permissionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.vertical / 2).isActive = true
        permissionLabel.bottomAnchor.constraint(equalTo: lineView.topAnchor, constant: -Spacing.vertical / 2).isActive = true
        permissionLabel.leadingAnchor.constraint(equalTo: checkImageView.trailingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        
        lineView.applyConstraints()
        
    }
    
    func configure(with viewModel: PermissionOptionCellViewModel, backgroundColorSubject: BehaviorSubject<UIColor>) {
        
        viewModel.isSelectedDriver
            .map { $0 ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle")}
            .drive(checkImageView.rx.image)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.isSelectedDriver.asObservable(), backgroundColorSubject)
            .map { isSelected, backgroundColor -> UIColor in
                if isSelected {
                    return UIColor.lightGray.withAlphaComponent(0.5)
                } else {
                    return backgroundColor
                }
            }.asDriver(onErrorJustReturn: .white)
            .drive(self.contentView.rx.backgroundColor)
            .disposed(by: disposeBag)
            
        
        viewModel.title
            .drive(self.permissionLabel.rx.text)
            .disposed(by: disposeBag)
        
    }
    
}
