//
//  NotificationViewController.swift
//  ImageNotification
//
//  Created by Laura Corssac on 6/9/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import UserNotifications
import Kingfisher
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak private var noficationImageView: UIImageView!
    
    func didReceive(_ notification: UNNotification) {
        
        self.noficationImageView.kf.setImage(with: notification.getImageURL())
            
    }

}
