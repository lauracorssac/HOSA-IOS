//
//  ControlCellViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/26/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum SwitchState: String {
    case on, off, loading
}

final class ControlCellViewModel {
    
    let shouldPresentErrorDriver: Driver<Error?>
    private let shouldPresentError = ReplaySubject<Error?>.create(bufferSize: 1)
    private let shouldRefresh: BehaviorSubject<Bool>
    
    let id: String
    let title: Driver<String>
    var userSwitched = PublishSubject<Bool>()
    private let switchState = ReplaySubject<SwitchState>.create(bufferSize: 1)
    let switchStateDriver: Driver<SwitchState>
    let description = ReplaySubject<String>.create(bufferSize: 1)
    let descriptionDriver: Driver<String>
    let controlShouldBeEnabled: BehaviorSubject<Bool>
    
    private let disposeBag = DisposeBag()
    
    init(item: Topic, shouldRefresh: BehaviorSubject<Bool>, itemTitle: ItemTitle, controlShouldBeEnabled: BehaviorSubject<Bool>, server: CommunicationManager) {
        
        
        self.switchStateDriver = self.switchState.asDriver(onErrorJustReturn: .off)
        self.descriptionDriver = description.asDriver(onErrorJustReturn: "")
        
        self.shouldRefresh = shouldRefresh
        var itemTitle = itemTitle
        self.id = item.id
        self.title = Driver<String>.of(itemTitle.mainTitle)
        self.controlShouldBeEnabled = controlShouldBeEnabled
        self.shouldPresentErrorDriver = shouldPresentError.asDriver(onErrorJustReturn: nil)
        
        userSwitched
            .map { _ in .loading }
            .bind(to: self.switchState)
            .disposed(by: disposeBag)
        
       let userInputHandleResult = userSwitched
        .withLatestFrom(ManagersManager.shared.credentialsManager.tokenString, resultSelector: { ($0, $1) })
        .flatMapLatest({ switchValue, token in
            ManagersManager.shared.communicationManager.handleUserInput(value: switchValue, item: item, token: token).materialize()
        }).share(replay: 1)
        
        userInputHandleResult
            .map { $0.error }
            .filter { $0 != nil }
            .bind(to: self.shouldPresentError)
            .disposed(by: disposeBag)
        
        userInputHandleResult
            .map { $0.error }
            .filter { $0 != nil }
            .withLatestFrom(userSwitched)
            .map { $0 ? .off : .on }
            .bind(to: self.switchState)
            .disposed(by: disposeBag)
        
         userInputHandleResult
            .map { $0.element }
            .filter { $0 != nil }
            .withLatestFrom(userSwitched)
            .map { $0 ? .on : .off }
            .bind(to: self.switchState)
            .disposed(by: disposeBag)

        self.switchState
            .map {
                return "The \(itemTitle.descriptionTitle) is currently " + $0.rawValue
            }
            .bind(to: description)
            .disposed(by: disposeBag)
        
        self.shouldRefresh
            .map { _ in .loading}
            .bind(to: self.switchState)
            .disposed(by: disposeBag)
        
        let refreshResult = self.shouldRefresh
            .filter { $0 }
            .flatMapLatest { _ in
                return server.refresh(item: item).materialize()
        }.share(replay: 1)
        
        refreshResult
            .map { $0.error }
            .filter { $0 != nil }
            .bind(to: self.shouldPresentError)
            .disposed(by: disposeBag)
        
        refreshResult
            .map { $0.error }
            .filter { $0 != nil }
            .map { _ in .off }
            .bind(to: self.switchState)
            .disposed(by: disposeBag)
        
        refreshResult
            .map { $0.element }
            .filter { $0 != nil }
            .map { $0! == 1.0 ? .on : .off }
            .bind(to: self.switchState)
            .disposed(by: disposeBag)
        
        ManagersManager.shared
            .communicationManager
            .didReceiveRemoteUpdate
            .filter { $0.1 == item.id }
            .map { $0.0 ? .on : .off }
            .bind(to: self.switchState)
            .disposed(by: disposeBag)
        
    }
    
}
