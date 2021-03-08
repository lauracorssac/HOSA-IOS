//
//  PermissionsChoosingViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/17/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PermissionsChoosingViewModel {
    
    let viewModelsDriver: BehaviorSubject<[PermissionOptionCellViewModel]>
    let continueButtonPressed = PublishSubject<Void>()
    let isLoadingDriver: Driver<Bool>
    let continueButtonShouldBeEnabledDriver: Driver<Bool>
    let errorDriver: Driver<Error?>
    let closeButtonPressed = PublishSubject<Void>()
    
    private let continueButtonShouldBeEnabled = BehaviorSubject<Bool>(value: false)
    private let errorSubject = ReplaySubject<Error?>.create(bufferSize: 1)
    private let disposeBag = DisposeBag()
    private let isLoading = BehaviorSubject<Bool>(value: false)
    
    init(stepper: PublishSubject<Step>) {
        
        self.isLoadingDriver = isLoading.asDriver(onErrorJustReturn: false)
        self.errorDriver = errorSubject.asDriver(onErrorJustReturn: nil)
        self.continueButtonShouldBeEnabledDriver = continueButtonShouldBeEnabled.asDriver(onErrorJustReturn: false)
        
        let isSelectedArray = [BehaviorSubject<Bool>(value: false), BehaviorSubject<Bool>(value: false), BehaviorSubject<Bool>(value: false)]
        let titleArray = [Observable.of("Live View"), Observable.of("System Control"), Observable.of("Token Generation")]
        
        let viewModels = zip(isSelectedArray, titleArray).map { isSelected, title in
            PermissionOptionCellViewModel(title: title, isSelected: isSelected)
        }
        
        viewModelsDriver = BehaviorSubject<[PermissionOptionCellViewModel]>(value: viewModels)
        
        let latestIsSelected = Observable
            .combineLatest(isSelectedArray)
        
        let latestTitle = Observable
            .combineLatest(titleArray)
        
        let requestResult = continueButtonPressed
            .withLatestFrom(latestIsSelected)
            .withLatestFrom(latestTitle, resultSelector: { ($0, $1 )})
            .map { isSelectedArray, stringArray in
                isSelectedArray.enumerated().map { i, isSelected in
                    isSelected ? stringArray[i] : ""
                }.filter { !$0.isEmpty }
            }
            .withLatestFrom(ManagersManager.shared.credentialsManager.tokenString, resultSelector: { ($0, $1 )})
            .flatMapLatest({ permissions, token in
                ManagersManager.shared.tokenManager.getNewToken(permissions: permissions, userToken: token).materialize()
            })
            .share(replay: 1)

        requestResult
            .map { $0.error }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)

        requestResult
            .map { $0.element }
            .filter { $0 != nil }
            .map { .didFinishTokenGeneration(token: $0!) }
            .bind(to: stepper)
            .disposed(by: disposeBag)
        
        continueButtonPressed
            .map { _ in true }
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        requestResult
            .map { _ in false }
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(isLoading, latestIsSelected)
            .map { isLoading, isSelectedArray in
                return !isLoading && isSelectedArray.contains(true)
            }
            .bind(to: continueButtonShouldBeEnabled)
            .disposed(by: disposeBag)
        
        closeButtonPressed
            .map { .close }
            .bind(to: stepper)
            .disposed(by: disposeBag)
            
    }
    
}
