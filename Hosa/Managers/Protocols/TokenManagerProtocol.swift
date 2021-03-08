//
//  TokenManagerProtocol.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/6/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

protocol TokenManagerProtocol {
    func deleteToken(tokenToDelete: String, userToken: String) -> Observable<Bool>
    func getAllTokens(userToken: String)-> Observable<[HosaToken]>
    func getNewToken(permissions: [String], userToken: String) -> Observable<String>
    func validateTokenGeneral(token: String) -> Observable<Bool>
}
