//
//  AppCoordinator.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/29/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import RxSwift

class AppCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    let tabbarController: UIViewController
    private let disposeBag = DisposeBag()
    
    init(tabbarController: UITabBarController) {
        self.tabbarController = tabbarController
        super.init()
        
        if ManagersManager.shared.credentialsManager.getToken().isEmpty {
            self.showTokenInputCoordinator()
        }
        
        ManagersManager.shared
            .credentialsManager
            .tokenStringToValidade
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] newToken in
                
                guard let self = self else { return }
                self.showTokenInputCoordinator()
                
            }).disposed(by: disposeBag)

    }
    
    func showTokenInputCoordinator() {
       
        let nav = UINavigationController()
        let tokenInputCoordinator = TokenInputCoordinator(navigationController: nav)
        
        nav.navigationItem.largeTitleDisplayMode = .automatic
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.prefersLargeTitles = true
       
        DispatchQueue.main.async {
            self.tabbarController.present(nav, animated: true, completion: nil)
            tokenInputCoordinator.start()
            self.childCoordinators.append(tokenInputCoordinator)
        }
        
        tokenInputCoordinator
            .didFinish
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
            
                nav.dismiss(animated: true, completion: nil)
                _ = self?.childCoordinators.popLast()
                
            }).disposed(by: disposeBag)

    }
    
    func showDetails(for newNotification: UNNotification ) {
        
        let vm = NotificationDetailsViewModel(with: newNotification)
        let vc = NotificationDetailsViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationItem.largeTitleDisplayMode = .automatic
        nav.navigationBar.sizeToFit()
        nav.modalPresentationStyle = .fullScreen
        
        nav.navigationBar.prefersLargeTitles = true
        vc.title = "Danger Alert"
        DispatchQueue.main.async {
            self.tabbarController.present(nav, animated: true, completion: nil)
        }
        
    }
    
}

extension AppCoordinator: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            break
            
        default:
            
            let notification = response.notification
            self.showDetails(for: notification)
            
        }
        
        completionHandler()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
