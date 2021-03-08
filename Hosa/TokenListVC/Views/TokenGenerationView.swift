//
//  TokenGenerationView.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/13/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class TokenGenerationView: UIView {
    
    let getTokenButton = UIButton()
    private let disposeBag = DisposeBag()
    private let viewModel: TokenGenerationViewViewModel
    
    init(viewModel: TokenGenerationViewViewModel) {
         
        // MARK: - Init
        
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        let titleLabel = UILabel()
        let informationText = UITextView()
        
        // MARK: - UI
        
        getTokenButton.showsTouchWhenHighlighted = true
        getTokenButton.setTitle("Generate first Token", for: .normal)
        getTokenButton.backgroundColor = Colors.green
        informationText.delegate = self
        informationText.font = UIFont.systemFont(ofSize: 11, weight: .light)
        informationText.isUserInteractionEnabled = true
        informationText.isEditable = false
        
        // MARK: - Layout
        
        self.addSubviews([getTokenButton, titleLabel, informationText])
        getTokenButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        getTokenButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        getTokenButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        getTokenButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: Spacing.vertical/2).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -Spacing.vertical/2).isActive = true
        
        informationText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        informationText.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        informationText.topAnchor.constraint(equalTo: getTokenButton.bottomAnchor, constant: Spacing.vertical/2).isActive = true
        informationText.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // MARK: - RX
        
        viewModel
            .informationString
            .drive(informationText.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel
            .emptyStateTokens
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TokenGenerationView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        self.viewModel.moreInfoButtonPressed.onNext(())
        return true
    }
}
