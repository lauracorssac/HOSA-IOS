//
//  NotificationViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/10/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UserNotifications
import RxSwift
import RxCocoa

final class NotificationDetailsViewModel: NSObject {

    private let dateString: BehaviorSubject<String>
    
    let imageURLDriver: Driver<URL?>
    let image = ReplaySubject<UIImage?>.create(bufferSize: 1)
    let dateStringDriver: Driver<String>
    let shouldDismissDriver: Driver<Bool>
    let shouldPresentImageAlertDriver: Driver<Bool>
    let shouldPresentDismissConfirmationAlertDriver: Driver<Bool>
    let shouldPresentErrorDriver: Driver<Error?>
   
    private let shouldDismiss = BehaviorSubject<Bool>(value: false)
    private let shouldPresentImageAlert = BehaviorSubject<Bool>(value: false)
    private let shouldPresentDismissConfirmationAlert = BehaviorSubject<Bool>(value: false)
    private let shouldPresentErrorAlert = BehaviorSubject<Error?>(value: nil)
    
    //SAVE IMAGE ALERT ACTIONS
    let saveImageButtonPressed = PublishSubject<Void>()
    let discardImageButtonPressed = PublishSubject<Void>()
    
    //DANGER REVIEW BUTTONS
    let dangerConfirmationButtonPressed = PublishSubject<Void>()
    let dangerDismissButtonPressed = PublishSubject<Void>()
    
    //DANGER DISMISS CONFIRMATION ALERT ACTIONS
    let dangerDismissConfirmationButtonPressed = PublishSubject<Void>()
    
    
    private let disposeBag = DisposeBag()

    init(with notification: UNNotification) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyy - HH:mm"
        dateString = BehaviorSubject<String>(value: formatter.string(from: notification.date))
        
        self.imageURLDriver = Driver.of(notification.getImageURL())
        
        self.dateStringDriver = dateString.asDriver(onErrorJustReturn: "")
        self.shouldDismissDriver = shouldDismiss.asDriver(onErrorJustReturn: false)
        self.shouldPresentImageAlertDriver = shouldPresentImageAlert.asDriver(onErrorJustReturn: false)
        self.shouldPresentDismissConfirmationAlertDriver = shouldPresentDismissConfirmationAlert.asDriver(onErrorJustReturn: false)
        self.shouldPresentErrorDriver = shouldPresentErrorAlert.asDriver(onErrorJustReturn: nil)
        
        super.init()
        
        // IMAGE ALERT ACTIONS
        saveImageButtonPressed
            .withLatestFrom(image)
            .subscribe(onNext: { [weak self] image in
                guard let self = self, let image = image else { return }
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveError), nil)
            }).disposed(by: disposeBag)
        
        discardImageButtonPressed
            .map { _ in true }
            .bind(to: shouldDismiss)
            .disposed(by: disposeBag)
        
        //DANGER REVIEW BUTTONS
        dangerConfirmationButtonPressed
            .debug()
            .map { _ in true }
            .bind(to: shouldPresentImageAlert)
            .disposed(by: disposeBag)
        
        dangerDismissButtonPressed
            .map { _ in true }
            .bind(to: self.shouldPresentDismissConfirmationAlert)
            .disposed(by: disposeBag)
            
        //DANGER DISMISS CONFIRMATION ALERT ACTIONS
        let dangerDismissHandleResponse = dangerDismissConfirmationButtonPressed
            .flatMapLatest({
                ManagersManager.shared.communicationManager.handleDismissOfDanger().materialize()
            }).share()
            
            
        dangerDismissHandleResponse
            .map { $0.error }
            .bind(to: self.shouldPresentErrorAlert)
            .disposed(by: disposeBag)
        
        dangerDismissHandleResponse
            .map { $0.element }
            .filter { $0 != nil }
            .map { _ in true }
            .bind(to: self.shouldDismiss )
            .disposed(by: self.disposeBag)
        
        dangerDismissConfirmationButtonPressed
            .map { _ in true }
            .bind(to: shouldDismiss)
            .disposed(by: disposeBag)
        
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
         self.shouldDismiss.onNext(true)
    }

}
