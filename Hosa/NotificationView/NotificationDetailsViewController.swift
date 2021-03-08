//
//  NotificationDetailsViewController.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/10/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher
import RxCocoa

final class NotificationDetailsViewController: UIViewController {
    
    private let viewModel: NotificationDetailsViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: NotificationDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?
            .rx.tap
            .throttle(.milliseconds(5), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: false)
            }).disposed(by: disposeBag)
        
        
        view.backgroundColor = .white

        let scrollView = UIScrollView()
        let contentView = UIView()
        let dateLabel = UILabel()
        let suspectImageView = UIImageView()
        suspectImageView.contentMode = .scaleAspectFit
        let dangerButton = UIButton(type: .system)
        let notDangerButton = UIButton(type: .system)

        view.addSubviews([scrollView])
        scrollView.applyAnchorsToSuperView()
       
        scrollView.addSubviews([contentView])
        contentView.applyAnchorsToSuperView()
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        contentView.addSubviews([dateLabel, suspectImageView, dangerButton, notDangerButton])
        dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing ).isActive = true

        suspectImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        suspectImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        suspectImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Spacing.vertical).isActive = true

        dangerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        dangerButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant:  -Spacing.leadingAndTrailing / 2 ).isActive = true
        dangerButton.topAnchor.constraint(equalTo: suspectImageView.bottomAnchor, constant: Spacing.vertical).isActive = true
        dangerButton.heightAnchor.constraint(equalToConstant: 64).isActive = true

        notDangerButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: Spacing.leadingAndTrailing / 2).isActive = true
        notDangerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        notDangerButton.topAnchor.constraint(equalTo: suspectImageView.bottomAnchor, constant: Spacing.vertical).isActive = true
        notDangerButton.heightAnchor.constraint(equalToConstant: 64).isActive = true

        dangerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.vertical).isActive = true
        notDangerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.vertical).isActive = true

        dangerButton.setTitle("DANGER", for: .normal)
        dangerButton.layer.cornerRadius = 32
        dangerButton.layer.borderWidth = 2
        dangerButton.layer.borderColor = Colors.red.cgColor
        dangerButton.backgroundColor = Colors.red
        dangerButton.tintColor = UIColor.white
        
        notDangerButton.setTitle("SAFE", for: .normal)
        notDangerButton.layer.cornerRadius = 32
        notDangerButton.layer.borderWidth = 2
        notDangerButton.layer.borderColor = Colors.green.cgColor
        notDangerButton.backgroundColor = Colors.green
        notDangerButton.tintColor = UIColor.white

        viewModel.imageURLDriver
            .drive(onNext: { imageURL in
                suspectImageView.kf.setImage(with: imageURL, completionHandler:  { [weak self] result in
                    switch result {
                    case let .success(value):
                        self?.viewModel.image.onNext(value.image)
                        self?.view.layoutIfNeeded()
                    case .failure(_):
                        return
                    }
                })
                
            }).disposed(by: disposeBag)
    
        viewModel.dateStringDriver
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)

        dangerButton.rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .bind(to: self.viewModel.dangerConfirmationButtonPressed)
            .disposed(by: disposeBag)

        notDangerButton.rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .bind(to: self.viewModel.dangerDismissButtonPressed)
            .disposed(by: disposeBag)

        viewModel.shouldDismissDriver
            .filter { $0 }
            .debug()
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)

        viewModel
            .shouldPresentImageAlertDriver
            .filter { $0 }
            .drive(onNext: { [weak self] _ in
                self?.presentImageAlert()
            }).disposed(by: disposeBag)
        
        viewModel.shouldPresentErrorDriver
            .filter { $0 != nil }
            .drive(onNext: { [weak self] _ in
                self?.presentErrorAlert()
            }).disposed(by: self.disposeBag)

        viewModel
        .shouldPresentDismissConfirmationAlertDriver
        .filter { $0 }
        .drive(onNext: { [weak self] _ in
            self?.discardDangerAlert()
        }).disposed(by: disposeBag)
    }
    
    private func presentImageAlert() {
        
        let alert = UIAlertController(title: "Would you like to save the image to gallery?", message: nil, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .default) { [weak self] action in
            self?.viewModel.discardImageButtonPressed.onNext(())
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] action in
            self?.viewModel.saveImageButtonPressed.onNext(())
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    private func discardDangerAlert() {
        let alert = UIAlertController(title: "Are you sure it is not domething danger?", message: "If you confirm, the alarm will be deactivated", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes, shut it off!", style: .destructive) { [weak self] action in
            self?.viewModel.dangerDismissConfirmationButtonPressed.onNext(())
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

}
