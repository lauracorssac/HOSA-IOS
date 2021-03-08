//
//  HTTPManager.swift
//  MQTTTest
//
//  Created by Laura Corssac on 7/2/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct MBPPostBody: Codable {
    let value: Float
    let id: String
    let port: String
}

final class HTTPManager {
   
    private lazy var jsonDecoder = JSONDecoder()
    private var urlSession = URLSession(configuration: URLSessionConfiguration.default)
    private let disposeBag = DisposeBag()
    
    static let shared = HTTPManager()
    
    var didReceiveRemoteUpdate = PublishSubject<(Bool, String)>()
    
    private init() {
        
    }
    
    func doPost(of item: MBPPostBody, token: String) -> Observable<Void> {
        
            return Observable<Void>.create { observer in
                
                guard
                    let url = URL(string: DataManager.vmIP + ":\(item.port)/\(item.id)?token=\(token)"), //192.168.0.100
                    let jsonString = try? JSONSerialization.data(withJSONObject: ["value": item.value], options: .prettyPrinted)
                else {
                    observer.onError(NSError(domain: "ErrorDomain", code: 0, userInfo: [:]))
                    return Disposables.create()
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "post"
                request.addValue("application/json", forHTTPHeaderField:"Content-Type")
                request.addValue("Connection", forHTTPHeaderField:"Close")
                request.httpBody = jsonString
                let task = self.urlSession.dataTask(with: request) { _, response, error in
                    
                    if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                        observer.onNext(())
                        observer.onCompleted()
                        return
                    }
                    
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    
                    observer.onError(NSError(domain: "Generic Error", code: 01, userInfo: nil))
                }
                
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            }
    }
    
    func doGet(path: String, port: String) -> Observable<Double> {
        
            return Observable<Double>.create { observer in
                
                guard
                    let url = URL(string: DataManager.vmIP + ":\(port)/\(path)") //192.168.0.100
                else {
                    observer.onError(NSError(domain: "ErrorDomain", code: 0, userInfo: [:]))
                    return Disposables.create()
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "get"
                let task = self.urlSession.dataTask(with: request) { data, response, error in
                    
                    if let error = error {
                        observer.onError(error)
                    } else
                        if let data = data,
                        let jsonData = try? JSONDecoder().decode([String: String].self, from: data),
                        let value = jsonData["value"],
                        let doubleValue = Double(value) {
                            observer.onNext(doubleValue)
                            observer.onCompleted()
                        } else {
                             observer.onError(NSError(domain: "Could not parse response", code: 01, userInfo: nil))
                    }
                    
                }
                
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            }
    }
    
}

extension HTTPManager: CommunicationManager {
    
    func handleDismissOfDanger() -> Observable<Void> {
        let postBody = MBPPostBody(value: 0.0, id: DataManager.buzzerSensorID, port: DataManager.buzzerSensorPort)
        return self.doPost(of: postBody, token: "") // TODO: fix this
    }
    
    func handleUserInput(value: Bool, item: Topic, token: String) -> Observable<Void> {
        let body = MBPPostBody(value: value ? 1.0 : 0.0, id: item.id, port: item.port)
        return self.doPost(of: body, token: token)
        
    }
    
    func refresh(item: Topic) -> Observable<Double> {
        return self.doGet(path: item.id, port: item.port)
    }
    
}
