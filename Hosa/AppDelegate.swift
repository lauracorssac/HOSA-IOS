//
//  AppDelegate.swift
//  MQTTTest
//
//  Created by Laura Corssac on 5/18/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            guard settings.authorizationStatus == .authorized else { return }
           
            let viewAction = UNNotificationAction(identifier: "VIEW_IDENTIFIER", title: "View", options: [.foreground])
            let testNotificationCategory = UNNotificationCategory(identifier: "imageNotificationCategory", actions: [viewAction], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([testNotificationCategory])
            
            DispatchQueue.main.async {
               
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
    }
    
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                print("Permission granted: \(granted)")
                self?.getNotificationSettings()
        }
    }
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        if
            let aps = userInfo[Constants.NotificationKeys.aps.rawValue] as? [String: Any],
            aps[Constants.NotificationKeys.contentAvailable.rawValue] as? Int == 1,
            let id = userInfo[Constants.NotificationKeys.id.rawValue] as? String,
            let stringValue = userInfo[Constants.NotificationKeys.value.rawValue] as? String,
            let value =  Double(stringValue) {
            //it is about a silent push
            ManagersManager.shared.communicationManager.didReceiveRemoteUpdate.onNext((value == 1.0, id))
            
            print(userInfo)
            completionHandler(.newData)
            
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
    
}

