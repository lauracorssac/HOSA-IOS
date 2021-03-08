//
//  CommunicationManager.swift
//  MQTTTest
//
//  Created by Laura Corssac on 10/6/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

protocol CommunicationManager {
    
    func handleDismissOfDanger() -> Observable<Void>
    func handleUserInput(value: Bool, item: Topic, token: String) -> Observable<Void>
    func refresh(item: Topic) -> Observable<Double>
    
    var didReceiveRemoteUpdate: PublishSubject<(Bool, String)> { get }
}

