//
//  TokenGenerationCoordinator.swift
//  Hosa
//
//  Created by Laura Corssac on 10/23/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

final class TokenGenerationCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    let disposeBag = DisposeBag()
    let stepper = PublishSubject<Step>()
    
    init(navigationController: UINavigationController, didFinish: PublishSubject<Void>) {
        self.navigationController = navigationController
        
        stepper
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] step in
                
                switch step {
                
                case let .didFinishTokenGeneration(tokenString):
                    self?.presentTokenSharing(tokenString: tokenString)
                    
                case .close:
                    self?.navigationController.dismiss(animated: true, completion: {
                        didFinish.onNext(())
                    })
                default:
                    break
                }
                
            }).disposed(by: disposeBag)

    }
    
    func start() {
        
        let vm = PermissionsChoosingViewModel(stepper: stepper)
        let vc = PermissionsChoosingViewController(viewModel: vm )
        vc.title = "Choose permissions"
        
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func presentTokenSharing(tokenString: String) {
        
        let vc = TokenSharingViewController(viewModel: TokenSharingViewModel(tokenString: tokenString, stepper: stepper), shouldHideCloseButton: false)
        vc.title = "Share Token"
        navigationController.pushViewController(vc, animated: true)
        
    }
}
