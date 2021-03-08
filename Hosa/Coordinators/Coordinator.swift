//
//  Coordinator.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/29/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
}
