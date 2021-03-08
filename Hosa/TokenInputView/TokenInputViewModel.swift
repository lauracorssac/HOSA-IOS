//
//  TokenInputViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/1/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class TokenInputViewModel {

    let tokenStringDriver: Driver<String>
    let viewState: Driver<ViewState>
    let informationString: Driver<NSAttributedString>
    let errorToPresentDriver: Driver<HosaError?>
    let continueButtonShouldBeEnabledDriver: Driver<Bool>
    
    let buttonPressed = PublishSubject<Void>()
    let textTyped = PublishSubject<String>()
    let pasteButtonPressed = PublishSubject<Void>()
    let moreInfoButtonPressed = PublishSubject<Void>()
    
    private let textToValidate = PublishSubject<String>()
    private let viewStateSubject = BehaviorSubject<ViewState>(value: .loaded)
    private let tokenString = ReplaySubject<String>.create(bufferSize: 1)
    private let continueButtonShouldBeEnabled = BehaviorSubject<Bool>(value: false)
    private let errorToPresent = BehaviorSubject<HosaError?>(value: nil)
    private let disposeBag = DisposeBag()
    
    init(didFinish: PublishSubject<Void>, stepper: PublishSubject<Step>) {
        
        tokenStringDriver = tokenString.asDriver(onErrorJustReturn: "")
        viewState = viewStateSubject.asDriver(onErrorJustReturn: .loaded)
        continueButtonShouldBeEnabledDriver = continueButtonShouldBeEnabled.asDriver(onErrorJustReturn: false)
        errorToPresentDriver = errorToPresent.asDriver(onErrorJustReturn: nil)
        
        let infoString = NSMutableAttributedString(string: "Wondering why are you in this screen?\nIt may be either because you had a token previoslly and it expired or because it is your first access and you haven't provided a token yet. ")
        let knowMore = NSAttributedString(string: "Know More.", attributes: [NSAttributedString.Key.link: ""])
        infoString.append(knowMore)
        
        informationString = Driver<NSAttributedString>.of( infoString )

        let shouldRequestToken = Observable
            .merge(textToValidate,
                   ManagersManager.shared.credentialsManager.tokenStringToValidade)
            .filter { !$0.isEmpty }
            .share(replay: 1)
        
        let currentTextInTextField = Observable
            .merge(tokenString, textTyped)
            .share(replay: 1)
        
        let tokenValidationResult = shouldRequestToken
            .filter { !$0.isEmpty }
            .flatMap {
                ManagersManager.shared.tokenManager.validateTokenGeneral(token: $0).materialize()
            }
            .share(replay: 1)
        
        shouldRequestToken
            .filter { !$0.isEmpty }
            .map { _ in .loading }
            .bind(to: viewStateSubject)
            .disposed(by: disposeBag)
        
        tokenValidationResult
            .map { $0.element }
            .filter { $0 != nil }
            .map { _ in .loaded }
            .bind(to: viewStateSubject)
            .disposed(by: disposeBag)
        
        tokenValidationResult
            .map { $0.element }
            .filter { $0 != nil }
            .map { _ in Void() }
            .bind(to: didFinish)
            .disposed(by: disposeBag)
        
        tokenValidationResult
            .map { $0.element }
            .filter { $0 != nil }
            .withLatestFrom(shouldRequestToken)
            .bind(to: ManagersManager.shared.credentialsManager.tokenString)
            .disposed(by: disposeBag)
        
        tokenValidationResult
            .map { $0.error }
            .filter { $0 != nil }
            .map { _ in .error }
            .bind(to: viewStateSubject)
            .disposed(by: disposeBag)
        
        tokenValidationResult
            .map { $0.error as? HosaError }
            .filter { $0 != nil }
            .bind(to: errorToPresent)
            .disposed(by: disposeBag)
        
        buttonPressed
            .withLatestFrom(currentTextInTextField)
            .bind(to: textToValidate)
            .disposed(by: disposeBag)
        
        pasteButtonPressed
            .map { _ in
                UIPasteboard.general.string ?? ""
            }
            .bind(to: tokenString)
            .disposed(by: disposeBag)
        
        ManagersManager.shared.credentialsManager
            .tokenStringToValidade
            .bind(to: tokenString)
            .disposed(by: disposeBag)
        
        let textNotEmpty = currentTextInTextField
            .map { !$0.isEmpty }
            
        Observable.combineLatest(textNotEmpty, viewStateSubject)
            .map { $0.0 && $0.1 != .loading }
            .bind(to: continueButtonShouldBeEnabled)
            .disposed(by: disposeBag)
        
        moreInfoButtonPressed
            .map { _ in .moreInformation}
            .bind(to: stepper)
            .disposed(by: disposeBag)
        
    }
}
