//
//  TokenInputViewController.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/1/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class TokenInputViewController: ViewController, UITextViewDelegate {
    
    private let viewModel: TokenInputViewModel
    private let disposeBag = DisposeBag()
    private  let informationTextView = UITextView()

    init(viewModel: TokenInputViewModel) {
       
        self.viewModel = viewModel
        super.init()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        let tokenTextField = UITextField()
        
        tokenTextField.clearButtonMode = .whileEditing
        tokenTextField.placeholder = "Enter Token"
        let validateButton = LoadableButton(title: "Validate")
        let pasteButton = UIButton()
        pasteButton.setImage(UIImage(systemName: "doc.on.clipboard.fill"), for: .normal)
        validateButton.applyStye(style: LoadableButtonStyle(backgroundColor: Colors.green))
        
        informationTextView.font = UIFont.systemFont(ofSize: 11, weight: .light)
        informationTextView.delegate = self
        informationTextView.isUserInteractionEnabled = true
        informationTextView.isEditable = false
        
        view.addSubviews([tokenTextField, validateButton, pasteButton, informationTextView])
        view.isUserInteractionEnabled = true
        
        tokenTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        tokenTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        tokenTextField.trailingAnchor.constraint(equalTo: pasteButton.leadingAnchor).isActive = true
        
        pasteButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        pasteButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        pasteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        pasteButton.centerYAnchor.constraint(equalTo: tokenTextField.centerYAnchor).isActive = true
        
        validateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        validateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        validateButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        validateButton.topAnchor.constraint(equalTo: tokenTextField.bottomAnchor, constant: Spacing.vertical).isActive = true
        
        informationTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        informationTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        informationTextView.topAnchor.constraint(equalTo: validateButton.bottomAnchor).isActive = true
        informationTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        viewModel
            .tokenStringDriver
            .drive(tokenTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel
            .viewState
            .map { $0 == .loading }
            .drive(validateButton.rx.isLoading)
            .disposed(by: disposeBag)
        
        viewModel
            .errorToPresentDriver
            .filter { $0 != nil }
            .drive { [weak self] error in
                self?.presentHosaErrorAlert(error: error)
            }.disposed(by: disposeBag)
        
        validateButton.rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .map { _ in Void() }
            .bind(to: viewModel.buttonPressed)
            .disposed(by: disposeBag)
        
        tokenTextField.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .asDriver(onErrorDriveWith: Driver<String>.of(""))
            .drive(viewModel.textTyped)
            .disposed(by: disposeBag)
        
        pasteButton.rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .map { _ in Void() }
            .bind(to: viewModel.pasteButtonPressed)
            .disposed(by: disposeBag)
        
        viewModel
            .continueButtonShouldBeEnabledDriver
            .drive(validateButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel
            .informationString
            .drive(informationTextView.rx.attributedText)
            .disposed(by: disposeBag)

    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        self.viewModel.moreInfoButtonPressed.onNext(())
        return true
    }
}
