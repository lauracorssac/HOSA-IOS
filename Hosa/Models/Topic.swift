//
//  SystemComponent.swift
//  MQTTTest
//
//  Created by Laura Corssac on 5/28/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation

struct Topic {
    let component: ComponentType
    let id: String
    let topicString: String
    let port: String
    
    init(id: String, componentType: ComponentType, port: String) {
        self.id = id
        self.component = componentType
        self.topicString = "\(componentType.rawValue)/\(id)"
        self.port = port
    }
}
