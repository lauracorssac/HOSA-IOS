//
//  ManagersManager.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/15/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation

class ManagersManager {
    
    let credentialsManager: CredentialsManager = UserDefaultsManager.shared
    let communicationManager: CommunicationManager = HTTPManager.shared
    let tokenManager: TokenManagerProtocol = TokenManager.shared
    
    static let shared = ManagersManager()
    
    private init() { }
    
}
