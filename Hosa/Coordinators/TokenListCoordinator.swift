//
//  TokenListCoordinator.swift
//  Hosa
//
//  Created by Laura Corssac on 10/23/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

final class TokenListViewCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    let disposeBag = DisposeBag()
    let stepper = PublishSubject<Step>()
    let shouldRequestNewTokens = BehaviorSubject<Bool>(value: true)
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let vm = TokenListViewModel(service: ManagersManager.shared.tokenManager,
                                          credentialsManager: ManagersManager.shared.credentialsManager,
                                          stepper: stepper,
                                          shouldRequestTokens: shouldRequestNewTokens)
        
        let tokenGenVC = TokenListViewController(viewModel: vm)
        navigationController.navigationBar.prefersLargeTitles = true
        tokenGenVC.title = "Access Control"
        tokenGenVC.tabBarItem.title = "Access Control"
        navigationController.tabBarItem = UITabBarItem(title: "Access Control", image: UIImage(systemName: "square.and.arrow.up"), tag: 2)
        
        navigationController.pushViewController(tokenGenVC, animated: true)
        
        stepper
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] step in
                
                switch step {
                case .generateNewToken:
                    self?.startTokenGenerationCoordinator()
                case let .seeDetails(token):
                    self?.showDetails(of: token)
                case .moreInformation:
                    self?.presentTokenInformation()
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func startTokenGenerationCoordinator() {
        
        let navController = UINavigationController()
        let didFinish = PublishSubject<Void>()
        let newCoordinator = TokenGenerationCoordinator(navigationController: navController,
                                                        didFinish: didFinish)
        
        newCoordinator.start()
        navigationController.present(navController, animated: true, completion: nil)
        self.childCoordinators.append(newCoordinator)
        
        didFinish
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
            
                _ = self?.childCoordinators.popLast()
                navController.dismiss(animated: true, completion: nil)
                self?.shouldRequestNewTokens.onNext(true)
                
            }).disposed(by: newCoordinator.disposeBag)
        
    }
    
    private func showDetails(of token: String) {
        
        let vc = TokenSharingViewController(viewModel: TokenSharingViewModel(tokenString: token, stepper: stepper ), shouldHideCloseButton: true)
        vc.title = "Share Token"
        navigationController.pushViewController(vc, animated: true)
        
    }
    
    private func presentTokenInformation() {
        
        let vc = TokenInformationViewController(viewModel: TokenGenerationInformationViewModel())
        vc.title = "What is a Token?"
        navigationController.pushViewController(vc, animated: true)
    }
    
}
