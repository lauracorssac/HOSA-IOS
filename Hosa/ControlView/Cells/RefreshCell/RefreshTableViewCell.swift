//
//  RefreshTableViewCell.swift
//  MQTTTest
//
//  Created by Laura Corssac on 7/14/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class RefreshTableViewCell: UITableViewCell {
    
    private var disposeBag = DisposeBag()
    private let refreshButton = UIButton()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
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
        
        self.contentView.addSubviews([refreshButton])
        refreshButton.applyDefaultAnchorsToSuperView()
        refreshButton.showsTouchWhenHighlighted = true
        refreshButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        refreshButton.backgroundColor = Colors.green
        
        refreshButton.setTitleColor(.black, for: .normal)
    }
    
    func configure(viewModel: RefreshCellViewModel) {
        refreshButton.setTitle(viewModel.title, for: .normal)
        
        refreshButton.rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .bind(to: viewModel.refreshButtonPressed)
            .disposed(by: disposeBag)
        
    }
    
}

