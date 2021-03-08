//
//  CredentialsManager.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/6/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

protocol CredentialsManager {
    func getToken() -> String
    func setToken(token: String)
    
    var tokenString: ReplaySubject<String> { get }
    var tokenStringToValidade: ReplaySubject<String> { get }
}
