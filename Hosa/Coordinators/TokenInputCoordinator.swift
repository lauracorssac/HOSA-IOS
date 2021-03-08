//
//  TokenInputCoordinator.swift
//  Hosa
//
//  Created by Laura Corssac on 10/27/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class TokenInputCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    let didFinish = PublishSubject<Void>()
    let stepper = PublishSubject<Step>()
    let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        stepper
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] step in
            
                switch step {
                
                case .moreInformation:
                    self?.presentMoreInformation()
                default:
                    break
                }
            
            }).disposed(by: disposeBag)
    }
    
    func start() {
        
        let vm = TokenInputViewModel(didFinish: didFinish, stepper: stepper)
        let vc = TokenInputViewController(viewModel: vm)
        vc.title = "Token Validation"
        DispatchQueue.main.async {
            self.navigationController.pushViewController(vc, animated: false)
        }
    }
    
    private func presentMoreInformation() {
        
        let vc = TokenInformationViewController(viewModel: TokenInformationViewModel())
        vc.title = "What is a Token?"
        navigationController.pushViewController(vc, animated: true)
        
    }
}
