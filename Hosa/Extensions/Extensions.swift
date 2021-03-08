//
//  Extensions.swift
//  MQTTTest
//
//  Created by Laura Corssac on 6/16/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import RxSwift
import RxCocoa

extension UNNotification {
    
    func getImage() -> UIImage? {
        
        guard
            let attachment = self.request.content.attachments.first,
            attachment.url.startAccessingSecurityScopedResource()
            else {
                return nil
        }
        
        let fileURLString = attachment.url
        
        guard
            let imageData = try? Data(contentsOf: fileURLString),
            let image = UIImage(data: imageData)
            else {
                attachment.url.stopAccessingSecurityScopedResource()
                return nil
        }
        return image
    }
    
    func getImageURL() -> URL? {
        
        guard
            self.request.content.userInfo.keys.contains("urlImageString"),
            let imageString = self.request.content.userInfo["urlImageString"] as? String
        else { return nil }
        
        return URL(string: imageString)
    }
    
}

extension UIView {
    
    func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(subview)
        }
    }
    
    func applyAnchors(to view: UIView) {
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    func applyAnchorsToSuperView(constant: CGFloat = 0) {
        guard let superView = self.superview else {
            return
        }
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: constant).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -constant).isActive = true
        self.topAnchor.constraint(equalTo: superView.topAnchor, constant: constant).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -constant).isActive = true
        
    }
    
    func applyDefaultAnchorsToSuperView() {
        guard let superView = self.superview else {
            return
        }
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: Spacing.leadingAndTrailing).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -Spacing.leadingAndTrailing).isActive = true
        self.topAnchor.constraint(equalTo: superView.topAnchor, constant: Spacing.vertical).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -Spacing.vertical).isActive = true
        
    }
    
    func centerToSuperview() {
        guard let superView = self.superview else {
            return
        }
        
        self.centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: 0).isActive = true
        self.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: 0).isActive = true
        
    }
    
}

extension UIViewController {
    
    func presentAlert(title: String, description: String, actionTitle: String) {
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(action)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentErrorAlert(error: NSError? = nil, title: String? = nil) {
        
        let description = (error != nil) ? error!.domain : ""
        
        self.presentAlert(title: "It was not possible to complete operation", description: description, actionTitle: "Ok :(")
        
    }
    
    func presentHosaErrorAlert(error: HosaError? = nil) {
        
        let description = (error != nil) ? error!.customDescription : ""
        let title = (error != nil) ? error!.customTitle : "It was not possible to complete operation"
        
        self.presentAlert(title: title, description: description ?? "", actionTitle: "Ok :(")
        
    }
    
    func presentSuccessAlert(message: String?) {
        
        let description = (message != nil) ? message! : ""
        
        self.presentAlert(title: "Operation completed successfully", description: description, actionTitle: "Ok :)")
        
    }
}

extension Reactive where Base: UIViewController {
    
    var shouldPresentError: Binder<Error?> {
        return Binder(self.base) { view, error in
            
            guard error != nil else { return }
            view.presentErrorAlert()
    
        }
    }
}

extension CIImage {
    func convertToUIImage() -> UIImage? {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(self, from: self.extent) else { return nil }
        let image = UIImage(cgImage: cgImage)
        return image
    }
}
