//
//  MainCoordinator.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/10/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import RxSwift

final class MainCoordinator: Coordinator {
    
    let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    let stepper = PublishSubject<Step>()
    
    let navigationController: UINavigationController
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
}

