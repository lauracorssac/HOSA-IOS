//
//  UserDefaultsManager.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/15/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class UserDefaultsManager: CredentialsManager {
    
    let tokenString = ReplaySubject<String>.create(bufferSize: 1)
    let tokenStringToValidade = ReplaySubject<String>.create(bufferSize: 1)
    
    static let shared = UserDefaultsManager()
    private let disposeBag = DisposeBag()
    
    private init() {
        
        tokenStringToValidade.onNext(self.getToken())
        
        tokenString
            .subscribe(onNext: { token in
                ManagersManager.shared.credentialsManager.setToken(token: token)
            }).disposed(by: disposeBag)

    }
    
    func getToken() -> String {
        return (UserDefaults.standard.value(forKey: Constants.UserDefaultsValue.token.rawValue) as? String) ?? ""
    }
    
    func setToken(token: String) {
        UserDefaults.standard.set(token, forKey: Constants.UserDefaultsValue.token.rawValue)
    }
 
}
