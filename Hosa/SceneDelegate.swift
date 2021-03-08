//
//  SceneDelegate.swift
//  MQTTTest
//
//  Created by Laura Corssac on 5/18/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit

import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let tabbarController = UITabBarController()
        
        let controlViewModel = ControlViewModel()
        let controlVC = ControlViewController(viewModel: controlViewModel)
        controlVC.tabBarItem = UITabBarItem.init(title: "Control", image: UIImage(systemName: "gear"), tag: 0)
        let navigationController = UINavigationController(rootViewController: controlVC)
        navigationController.navigationBar.prefersLargeTitles = true
        controlVC.title = "Control Panel"
        controlVC.tabBarItem.title = "Control Panel"
        
        let liveViewVC = LiveViewViewController(viewModel: LiveViewViewModel())
        liveViewVC.tabBarItem = UITabBarItem(title: "Live View", image: UIImage(systemName: "eye"), tag: 1)
        liveViewVC.tabBarItem.title = "Live View"
        liveViewVC.title = "Live View"
        
        let tokenGenNav = UINavigationController()
        let tokenViewCoordinator = TokenListViewCoordinator(navigationController: tokenGenNav)
       
        tabbarController.viewControllers = [navigationController, liveViewVC, tokenGenNav]
        tokenViewCoordinator.start()
        
        appCoordinator = AppCoordinator(tabbarController: tabbarController)
        appCoordinator?.childCoordinators.append(MainCoordinator(navigationController: navigationController))
        appCoordinator?.childCoordinators.append(tokenViewCoordinator)
        window.rootViewController = tabbarController
        self.window = window
        window.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().delegate = appCoordinator
               
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url =  userActivity.webpageURL,
            let components = URLComponents.init(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            let tokenKey = queryItems.first(where: { $0.name == "token" }),
            let tokenValue = tokenKey.value
        else { return }
        
        ManagersManager.shared.credentialsManager.tokenStringToValidade.onNext(tokenValue)
        
    }

}
