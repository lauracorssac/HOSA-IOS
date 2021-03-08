//
//  TokenSharingViewController.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/20/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxSwift

final class TokenSharingViewController: ViewController {
    
    let viewModel: TokenSharingViewModel
    let disposeBag = DisposeBag()
    let shouldHideCloseButton: Bool
    
    init(viewModel: TokenSharingViewModel, shouldHideCloseButton: Bool) {
       
        self.shouldHideCloseButton = shouldHideCloseButton
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView()
        let shareURLButton = LoadableButton()
        let saveQRCodeButton = LoadableButton()
        
        let scrollView = UIScrollView()
        let contentView = UIView()
        
        view.addSubviews([scrollView])
        scrollView.addSubviews([contentView])
        contentView.addSubviews([imageView, shareURLButton, saveQRCodeButton])
        
        contentView.applyAnchorsToSuperView()
        scrollView.applyAnchorsToSuperView()
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        if !shouldHideCloseButton {
            let closeItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil)
            self.navigationItem.setRightBarButton(closeItem, animated: false)
            
            closeItem.rx.tap
                .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
                .bind(to: viewModel.closeButtonPressed)
                .disposed(by: disposeBag)
          
        }
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.vertical).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        shareURLButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        shareURLButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        shareURLButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2 * Spacing.vertical).isActive = true
        shareURLButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        saveQRCodeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        saveQRCodeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        saveQRCodeButton.topAnchor.constraint(equalTo: shareURLButton.bottomAnchor, constant: Spacing.vertical).isActive = true
        saveQRCodeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        saveQRCodeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.vertical).isActive = true
        
        shareURLButton.applyStye(style: LoadableButtonStyleFabric.getStyleFor(type: .green))
        saveQRCodeButton.applyStye(style: LoadableButtonStyleFabric.getStyleFor(type: .green))
        
        saveQRCodeButton.setTitle("Save QR Code", for: .normal)
        shareURLButton.setTitle("Share URL", for: .normal)
        
        viewModel.qrImageDriver
            .drive(imageView.rx.image)
            .disposed(by: disposeBag)
        
        shareURLButton
            .rx.tap
            .throttle(.microseconds(5), scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.shareTokenDriver)
            .subscribe(onNext: { [weak self] text in
                let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
                self?.present(vc, animated: false, completion: nil)
            }).disposed(by: disposeBag)
        
        saveQRCodeButton
            .rx.tap
            .throttle(.microseconds(5), scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.qrImageDriver)
            .subscribe(onNext: { [weak self] image in
                
                guard let self = self, let image = image else { return }
                
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                                               nil)
                
            }).disposed(by: disposeBag)
      
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
       
        if let error = error {
            
            print(error)
            let error = NSError(domain: "Could not save the QR code", code: 0, userInfo: nil)
            self.presentErrorAlert(error: error)
            
        } else {
            
            self.presentSuccessAlert(message: "Image Saved to camera roll!")
        }
    }
}
