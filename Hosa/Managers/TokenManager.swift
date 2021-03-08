//
//  TokenManager.swift
//  MQTTTest
//
//  Created by Laura Corssac on 8/10/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift

struct HosaToken: Codable {
    
    let encodedValue: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case encodedValue = "encoded_token"
        case date
    }
    
}

class HosaError: NSError {
    
    let customTitle: String
    let customDescription: String?
    
    init(title: String, description: String?) {
        self.customTitle = title
        self.customDescription = description
        super.init(domain: "", code: 0, userInfo: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TokenManager: TokenManagerProtocol {
    
    static let shared = TokenManager()
    private init() {}
    
    func deleteToken(tokenToDelete: String, userToken: String) -> Observable<Bool> {
        
        return Observable<Bool>.create { observer in
            
            guard
                let url = URL(string: DataManager.herokuPath + "/delete_token?token=" + userToken)
                else {
                    observer.onError(NSError(domain: "ErrorDomain", code: 0, userInfo: [:]))
                    return Disposables.create()
            }
            var request = URLRequest(url: url)
            let postBody = ["token":  tokenToDelete]
            request.httpBody = try? JSONEncoder().encode(postBody)
            request.httpMethod = "post"
            request.addValue("application/json", forHTTPHeaderField:"Content-Type")
            let urlSession = URLSession(configuration: URLSessionConfiguration.default)
            
            let task = urlSession.dataTask(with: request) { data, response, error in
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    switch TokenManager.shared.parse(response: httpResponse) {
                    case .success:
                        observer.onNext(true)
                        observer.onCompleted()
                    case let .error(description: desc):
                        
                        let error = NSError(domain: desc, code: 01, userInfo: nil)
                        observer.onError(error)
                    }
                    
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
    
    func getAllTokens(userToken: String)-> Observable<[HosaToken]> {
        return Observable<[HosaToken]>.create { observer in
            
            guard
                let url = URL(string: DataManager.herokuPath + "/get_generated_tokens?token=" + userToken)
            else {
                observer.onError(NSError(domain: "ErrorDomain", code: 0, userInfo: [:]))
                return Disposables.create()
            }
            var request = URLRequest(url: url)
            request.httpMethod = "get"
            request.addValue("application/json", forHTTPHeaderField:"Content-Type")
            let urlSession = URLSession(configuration: URLSessionConfiguration.default)
            
            let task = urlSession.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    observer.onError(error)
                } else
                    
                    if let data = data,
                       let tokens = try? JSONDecoder().decode([HosaToken].self, from: data) {
                        observer.onNext(tokens)
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
    
    func getNewToken(permissions: [String], userToken: String) -> Observable<String> {
        
        return Observable<String>.create { observer in
            
            guard
                let url = URL(string: DataManager.herokuPath + "/get_token?token=" + userToken),
                let jsonString = try? JSONSerialization.data(withJSONObject: ["permissions": permissions], options: .prettyPrinted)
                else {
                    observer.onError(NSError(domain: "ErrorDomain", code: 0, userInfo: [:]))
                    return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "post"
            request.addValue("application/json", forHTTPHeaderField:"Content-Type")
            request.httpBody = jsonString
            let urlSession = URLSession(configuration: URLSessionConfiguration.default)
            
            let task = urlSession.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    observer.onError(error)
                } else
                    
                    if let data = data,
                        let jsonData = try? JSONDecoder().decode([String: String].self, from: data),
                        let value = jsonData["code"] {
                        observer.onNext(value)
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
    
    func validateTokenGeneral(token: String) -> Observable<Bool> {
        
        return Observable<Bool>.create { observer in
            
            guard
                let url = URL(string: DataManager.herokuPath + "/validate_token_general?token=" + token)
            else {
                observer.onError(NSError(domain: "ErrorDomain", code: 0, userInfo: [:]))
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "get"
            request.addValue("application/json", forHTTPHeaderField:"Content-Type")
            
            let urlSession = URLSession(configuration: URLSessionConfiguration.default)
            let task = urlSession.dataTask(with: request) { data, response, error in
           
                if let httpResponse = response as? HTTPURLResponse {
                    
                    switch TokenManager.shared.parse(response: httpResponse) {
                    case .success:
                        
                        observer.onNext(true)
                        observer.onCompleted()
                    case let .error(description: desc):
                            
                        let error = HosaError(title: desc, description: TokenManager.shared.parse(responseData: data))
                        observer.onError(error)
                    }
                    
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
    
    func parse(response: HTTPURLResponse) -> ResponseEnum {
        
        switch response.statusCode {
        case 200:
            return .success
        case 403:
            return .error(description: "You don't have permission to complete this operation")
        case 404:
            return .error(description: "The resources could not be found")
        case 500...600:
            return .error(description: "The operation couln't be completed due to general problems in the servers.")
        default:
            return .error(description: "Could not complete operation")
        }
    }
    
    func parse(responseData: Data?) -> String? {
        
        guard
            let dataResponse = responseData,
            let decoded = try? JSONSerialization.jsonObject(with: dataResponse, options: []),
            let errorDict = decoded as? [String:String],
            let desc = errorDict["error"]
        else { return nil }
       
        switch desc {
        case "expired":
            return "Reason: The token expired"
        case "invalid":
            return "Reason: The token is not valid"
        case "permission_not_granted":
            return "Reason: The token that you are using doesn't have this permission. Try talking to the person who created it!"
        default:
            return nil
        }
        
    }
    
}

enum ResponseEnum {
    case success
    case error(description: String)
}
