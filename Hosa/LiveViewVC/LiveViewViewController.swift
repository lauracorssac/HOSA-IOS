//
//  LiveViewViewController.swift
//  MQTTTest
//
//  Created by Laura Corssac on 5/26/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UIKit
import RxSwift
import WebKit
import RxCocoa

class LiveViewViewController: ViewController {

    private let errorView = ErrorView(descriptionText: "Not possible to load video")
    private let refreshButton = UIButton()
    private let loadingView = LoadingView()
    
    private let viewModel: LiveViewViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: LiveViewViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webAndReloadView = UIView()
        
        view.addSubviews([errorView, loadingView, webAndReloadView])
        errorView.applyDefaultAnchorsToSuperView()
        
        let guide = view.safeAreaLayoutGuide
        webAndReloadView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webAndReloadView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webAndReloadView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webAndReloadView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        
        loadingView.applyAnchorsToSuperView()
        
        refreshButton.backgroundColor = Colors.green
        refreshButton.setTitleColor(.black, for: .normal)
        refreshButton.setTitle("Refresh", for: .normal)
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        let webKitView = WKWebView(frame: .zero, configuration: wkWebConfig)
        
        webAndReloadView.addSubviews([webKitView, refreshButton])
        
        refreshButton.bottomAnchor.constraint(equalTo: webAndReloadView.bottomAnchor, constant: -Spacing.vertical).isActive = true
        refreshButton.leadingAnchor.constraint(equalTo: webAndReloadView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        refreshButton.trailingAnchor.constraint(equalTo: webAndReloadView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        webKitView.topAnchor.constraint(equalTo: webAndReloadView.topAnchor).isActive = true
        webKitView.leadingAnchor.constraint(equalTo: webAndReloadView.leadingAnchor).isActive = true
        webKitView.trailingAnchor.constraint(equalTo: webAndReloadView.trailingAnchor).isActive = true
        webKitView.bottomAnchor.constraint(equalTo: refreshButton.topAnchor, constant: -Spacing.vertical).isActive = true
        
        webKitView.navigationDelegate = self.viewModel
        
        self.viewModel.shouldRequestDriver
            .withLatestFrom(viewModel.streamURLDriver)
            .filter { $0 != nil }
            .map { $0! }
            .map { URLRequest(url: $0) }
            .drive(webKitView.rx.request)
            .disposed(by: disposeBag)

        viewModel
            .viewStateDriver
            .map { $0 == .loading}
            .drive(self.loadingView.rx.isLoading)
            .disposed(by: self.disposeBag)

        viewModel
            .viewStateDriver
            .map { $0 != .loaded}
            .drive(webAndReloadView.rx.isHidden)
            .disposed(by: self.disposeBag)

        viewModel
            .viewStateDriver
            .map { $0 != .error}
            .drive(self.errorView.rx.isHidden)
            .disposed(by: self.disposeBag)

        errorView.reloadButton
            .rx.tap
            .throttle(.milliseconds(5), scheduler: MainScheduler.instance)
            .bind(to: self.viewModel.reloadButtonPressed)
            .disposed(by: disposeBag)
        
        refreshButton.rx.tap
            .throttle(.microseconds(5), scheduler: MainScheduler.instance)
            .bind(to: viewModel.reloadButtonPressed)
            .disposed(by: disposeBag)
        
    }

}

extension Reactive where Base: WKWebView {
    var request: Binder<URLRequest> {
        return Binder(self.base) { view, value in
            view.load(value)
        }
    }
}
