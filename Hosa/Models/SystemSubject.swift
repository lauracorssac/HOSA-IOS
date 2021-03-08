//
//  SystemSubject.swift
//  MQTTTest
//
//  Created by Laura Corssac on 5/28/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation

// handles a sensor and actuator
struct SystemSubject {
    
    let actuatorToSubscribe: Topic
    let sensorToPublish: Topic
    let cellItem: ControlCellViewModel
    
}
