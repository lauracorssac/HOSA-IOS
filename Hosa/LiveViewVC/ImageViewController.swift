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

class LiveViewViewController: UIViewController {

    @IBOutlet private weak var webKitView: WKWebView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

}
