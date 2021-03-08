//
//  DataManager.swift
//  Hosa
//
//  Created by Laura Corssac on 3/5/21.
//  Copyright © 2021 Laura Corssac. All rights reserved.
//

import Foundation

final class DataManager {
    
    static let liveSteamPort = "8000"
    
    static let raspberryIP = "" // E.g.: http://192.168.0.103
    static let liveStreamURL = DataManager.raspberryIP + DataManager.liveSteamPort // E.g.: http://192.168.0.103:8000
    static let vmIP = "" //E.g.: http://193.196.54.151
    static let herokuPath = "" //E.g.: https://hidden-sea-12345.herokuapp.com
    
    static let systemSensorID = "PHONESYSTEMSENSOR"
    static let buzzerSensorID = "PHONEBUZZERSENSOR"
    
    static let systemSensorPort = "8084"
    static let buzzerSensorPort = "8082"
    
    private init() { }
    
}
