//
//  NotificationService.swift
//  ImageNotificationServiceExtension
//
//  Created by Laura Corssac on 6/9/20.
//  Copyright © 2020 Laura Corssac. All rights reserved.
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            return
        }
        
        guard let imageURLString =
            bestAttemptContent.userInfo["urlImageString"] as? String else {
                contentHandler(bestAttemptContent)
                return
        }
        
        getMediaAttachment(for: imageURLString) { [weak self] image in
            guard
                let self = self,
                let image = image,
                let fileURL = self.saveImageAttachment(
                    image: image,
                    forIdentifier: "attachment.png")
                else {
                    contentHandler(bestAttemptContent)
                    return
            }
            
            let imageAttachment = try? UNNotificationAttachment(
                identifier: "image",
                url: fileURL,
                options: nil)
            
            
            if let imageAttachment = imageAttachment {
                bestAttemptContent.attachments = [imageAttachment]
            }
            
            contentHandler(bestAttemptContent)
        }
        
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func saveImageAttachment(
      image: UIImage,
      forIdentifier identifier: String
    ) -> URL? {
      // 1
      let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
      // 2
      let directoryPath = tempDirectory.appendingPathComponent(
        ProcessInfo.processInfo.globallyUniqueString,
        isDirectory: true)

      do {
        // 3
        try FileManager.default.createDirectory(
          at: directoryPath,
          withIntermediateDirectories: true,
          attributes: nil)

        // 4
        let fileURL = directoryPath.appendingPathComponent(identifier)

        // 5
        guard let imageData = image.pngData() else {
          return nil
        }

        // 6
        try imageData.write(to: fileURL)
          return fileURL
        } catch {
          return nil
      }
    }

    private func getMediaAttachment(
      for urlString: String,
      completion: @escaping (UIImage?) -> Void
    ) {
      // 1
      guard let url = URL(string: urlString) else {
        completion(nil)
        return
      }

      // 2
      ImageDownloader.shared.downloadImage(forURL: url) { result in
        // 3
        guard let image = try? result.get() else {
          completion(nil)
          return
        }

        // 4
        completion(image)
      }
    }


}
