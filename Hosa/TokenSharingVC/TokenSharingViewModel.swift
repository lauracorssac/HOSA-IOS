//
//  TokenListViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/20/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class TokenSharingViewModel {
    
    let qrImageSubject: BehaviorSubject<UIImage?>
    let qrImageDriver: Driver<UIImage?>
    let shareTokenDriver: Driver<String>
    private let shareToken = ReplaySubject<String>.create(bufferSize: 1)
    let closeButtonPressed = ReplaySubject<Void>.create(bufferSize: 1)
    
    private let disposeBag = DisposeBag()
    
    init(tokenString: String, stepper: PublishSubject<Step>) {
        
        let linkString = DataManager.herokuPath + "/?token=" + tokenString
        
        let data = linkString.data(using: String.Encoding.ascii)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        
        qrFilter?.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 5, y: 5)
        let qrImage = qrFilter?.outputImage?.transformed(by: transform)
        let uiImage = qrImage?.convertToUIImage()
        
        self.qrImageSubject = BehaviorSubject<UIImage?>(value: uiImage)
        self.qrImageDriver = qrImageSubject.asDriver(onErrorJustReturn: nil)
        self.shareTokenDriver = shareToken.asDriver(onErrorJustReturn: "")
        
        Observable.of(linkString)
            .bind(to: shareToken)
            .disposed(by: disposeBag)
        
        closeButtonPressed
            .asNever()
            .map { _ in .close }
            .bind(to: stepper)
            .disposed(by: disposeBag)
        
    }
    
}

extension ObservableType {
    public func asNever() -> Observable<Element> {
        return Observable.create { o in
            return self.subscribe { element in
                switch element {
                case let .next(nextEvent):
                    o.onNext(nextEvent)
                case .error(_):
                    break
                case .completed:
                    break
                }
            }
        }
    }
}
