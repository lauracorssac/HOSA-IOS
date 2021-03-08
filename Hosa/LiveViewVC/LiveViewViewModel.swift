//
//  LiveViewViewModel.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/28/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import WebKit

enum ViewState {
    case loading
    case error
    case loaded
}

class LiveViewViewModel: NSObject {
    
    private let streamURLString = BehaviorSubject<String>(value: "")
    private let streamURL = ReplaySubject<URL?>.create(bufferSize: 1)
    
    private let disposeBag = DisposeBag()
    private let viewState = BehaviorSubject<ViewState>(value: .loading)
    private let isLoading = BehaviorSubject<Bool>(value: false)

    let viewStateDriver: Driver<ViewState>
    let streamURLDriver: Driver<URL?>
    let reloadButtonPressed = PublishSubject<Void>()
   
    let loadDidSucced = PublishSubject<Void>()
    let loadDidFail = PublishSubject<Error>()
    
    private let shouldRequest = PublishSubject<Bool>()
    let shouldRequestDriver: Driver<Bool>
    
    override init() {
        
        shouldRequestDriver = shouldRequest.asDriver(onErrorJustReturn: false)
        
        ManagersManager.shared
            .credentialsManager
            .tokenString
            .filter { !$0.isEmpty }
            .map { DataManager.liveStreamURL + "/?token=" + $0 }
            .bind(to: streamURLString)
            .disposed(by: disposeBag)
        
        streamURLString
            .map {  URL(string: $0)  }
            .bind(to: streamURL)
            .disposed(by: disposeBag)
        
        streamURL
            .filter { $0 == nil }
            .map { _ in .error }
            .bind(to: self.viewState)
            .disposed(by: self.disposeBag)
        
        viewStateDriver = viewState.asDriver(onErrorJustReturn: .error)
        streamURLDriver = streamURL.asDriver(onErrorJustReturn: nil)
        
        loadDidFail
            .map { _ in .error }
            .bind(to: self.viewState)
            .disposed(by: disposeBag)
        
        reloadButtonPressed
            .withLatestFrom(streamURL)
            .map { $0 == nil ? .error : .loading }
            .bind(to: self.viewState)
            .disposed(by: disposeBag)
        
        loadDidSucced
            .map { _ in .loaded }
            .bind(to: self.viewState)
            .disposed(by: disposeBag)
        
        reloadButtonPressed
            .map { _ in true }
            .bind(to: shouldRequest)
            .disposed(by: disposeBag)
        
        streamURLString
            .filter { !$0.isEmpty }
            .map { _ in true }
            .bind(to: shouldRequest)
            .disposed(by: disposeBag)
            
        super.init()
        
    }
    
}

extension LiveViewViewModel: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            if response.statusCode == 200 {
                decisionHandler(.allow)
                return
            }
        }
        decisionHandler(.cancel)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadDidSucced.onNext(())
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.loadDidFail.onNext(error)
    }
}
