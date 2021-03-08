//
//  TokenListViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/10/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokenListViewModel {
    
    let tokenButtonPressed = PublishSubject<Void>()
    let tryAgainButtonPressed = PublishSubject<Void>()
    let viewStateDriver: Driver<TokenViewState>
    let sectionList = BehaviorSubject<[TokenSectionModel]>(value: [])
    let deletedRow = PublishSubject<Int>()
    let shouldDisplayErrorAlertDriver: Driver<Error?>
    let modelSelected = PublishSubject<TokenTableViewCellViewModel>()
    let subViewModel: TokenGenerationViewViewModel
    
    private let shouldRequestTokens: BehaviorSubject<Bool>
    private let viewState = BehaviorSubject<TokenViewState>(value: .loading)
    private let tokenGenerated = ReplaySubject<HosaToken>.create(bufferSize: 1)
    private let shouldDismiss = PublishSubject<Bool>()
    
    private let disposeBag = DisposeBag()
    private let shouldDisplayErrorAlert = ReplaySubject<Error?>.create(bufferSize: 1)
    private let deletedItem = ReplaySubject<Int>.create(bufferSize: 1)
    
    private let credentialsManager: CredentialsManager
    private let refreshViewModel = BehaviorSubject<RefreshCellViewModel>(value: RefreshCellViewModel(title: "Generate new Token"))
    private let tokenViewModels = BehaviorSubject<[TokenTableViewCellViewModel]>(value: [])
    
    init(service: TokenManagerProtocol, credentialsManager: CredentialsManager,
         stepper: PublishSubject<Step>,
         shouldRequestTokens: BehaviorSubject<Bool>) {
        
        self.credentialsManager = credentialsManager
        self.viewStateDriver = viewState.asDriver(onErrorJustReturn: .empty)
        self.shouldDisplayErrorAlertDriver = shouldDisplayErrorAlert.asDriver(onErrorJustReturn: nil)
        self.shouldRequestTokens = shouldRequestTokens
        self.subViewModel = TokenGenerationViewViewModel(stepper: stepper)
        
        refreshViewModel
            .flatMapLatest {
                $0.refreshButtonPressed
            }.map { _ in .generateNewToken }
            .bind(to: stepper)
            .disposed(by: disposeBag)
        
        ManagersManager.shared.credentialsManager
            .tokenString
            .filter { !$0.isEmpty }
            .map { _ in true }
            .bind(to: shouldRequestTokens)
            .disposed(by: disposeBag)
        
        tryAgainButtonPressed
            .map { _ in true }
            .bind(to: shouldRequestTokens)
            .disposed(by: disposeBag)
        
        tryAgainButtonPressed
            .map { _ in .loading}
            .bind(to: viewState)
            .disposed(by: disposeBag)

        let tokensResponse = Observable
            .combineLatest(shouldRequestTokens, ManagersManager.shared.credentialsManager.tokenString)
            .filter { $0.0 && !$0.1.isEmpty }
            .flatMap { shouldRequest, token in
                service.getAllTokens(userToken: token).materialize()
            }.share(replay: 1)
        
        tokensResponse
            .map { $0.error }
            .filter {$0 != nil}
            .map { _ in .error}
            .bind(to: viewState)
            .disposed(by: disposeBag)
        
        tokensResponse
            .map { $0.element }
            .filter {$0 != nil }
            .map {$0!}
            .map {
                $0.map { TokenTableViewCellViewModel(token: $0) }
            }
            .bind(to: tokenViewModels)
            .disposed(by: disposeBag)
        
        tokenViewModels
            .skip(1)
            .filter { $0.isEmpty }
            .map { _ in .empty }
            .bind(to: viewState)
            .disposed(by: disposeBag)
        
        tokenViewModels
            .filter { !($0.isEmpty) }
            .map { _ in .success }
            .bind(to: viewState)
            .disposed(by: disposeBag)
        
        tokenButtonPressed
            .map { .generateNewToken }
            .bind(to: stepper)
            .disposed(by: disposeBag)
        
        tokenGenerated
            .withLatestFrom(tokenViewModels, resultSelector: {($0, $1)} )
            .map { newToken, tokens  in
                var tokenArray = tokens
                tokenArray.append(TokenTableViewCellViewModel(token: newToken))
                return tokenArray
            }
            .bind(to: tokenViewModels)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(tokenViewModels, refreshViewModel)
            .map { tokenViewModels, refreshViewModel in
                
                
                let tokenItems = tokenViewModels.map  { TokenSectionItem.tokenCell(viewModel: $0) }
                let tokenSectionModel = TokenSectionModel.tokenSection(title: "", items: tokenItems)

                let refreshItems = [TokenSectionItem.refresh(viewModel: refreshViewModel)]
                let refreshSectionModel = TokenSectionModel.refreshSection(title: "", items: refreshItems)

                return [tokenSectionModel, refreshSectionModel]
            }
            .bind(to: sectionList)
            .disposed(by: disposeBag)
        
        
        let viewModelToDelete = deletedRow
            .withLatestFrom(tokenViewModels, resultSelector: {($0, $1)})
            .map {  indexToDelete, viewModels in viewModels[indexToDelete] }
        
        viewModelToDelete
            .subscribe(onNext: { viewModel in
                viewModel.state.onNext(.loading)
            }).disposed(by: disposeBag)
        
        let deletionResult = viewModelToDelete
            .map {  $0.token.encodedValue }
            .withLatestFrom(ManagersManager.shared.credentialsManager.tokenString, resultSelector: {($0, $1)})
            .flatMapLatest { tokenToDelete, tokenUser in
                return ManagersManager.shared.tokenManager.deleteToken(tokenToDelete: tokenToDelete, userToken: tokenUser).materialize()
            }.share(replay:  1)
        
        deletionResult
            .withLatestFrom(viewModelToDelete)
            .subscribe(onNext: { viewModel in
                viewModel.state.onNext(.loaded)
            }).disposed(by: disposeBag)
        
        deletionResult
            .map { $0.error }
            .bind(to: shouldDisplayErrorAlert)
            .disposed(by: disposeBag)
        
        deletionResult
            .map { $0.element }
            .filter { $0 != nil }
            .withLatestFrom(tokenViewModels)
            .withLatestFrom(viewModelToDelete, resultSelector: {($0, $1)})
            .map { viewModels, viewModelToDelete in
                var varViewModels = viewModels
                varViewModels.removeAll(where: { $0.token.encodedValue == viewModelToDelete.token.encodedValue })
                return varViewModels
            }.bind(to: tokenViewModels)
            .disposed(by: disposeBag)
        
        modelSelected
            .map { tokenVM in .seeDetails(tokenVM.token.encodedValue) }
            .bind(to: stepper)
            .disposed(by: disposeBag)
        
    }
    
}
