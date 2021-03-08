//
//  Constants.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/10/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation

enum Constants {
    
    enum NotificationKeys: String {
        
        case aps
        case alert
        case sound
        case category
        case urlImageString
        case id
        case contentAvailable = "content-available"
        case value
    }
    
    enum UserDefaultsValue: String {
        case token
    }
    
}
