//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Hans Knöchel on 14.10.22.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    if let bestAttemptContent {
      defer {
        contentHandler(bestAttemptContent)
      }
      
      guard let attachment = request.attachment else { return }
      
      bestAttemptContent.attachments = [attachment]
    }
  }

  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content,
    // otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
}

// MARK: Override the "UNNotificationRequest" to grab the attachment from the "image_url" property inside the APS

extension UNNotificationRequest {
  var attachment: UNNotificationAttachment? {
  
    guard let attachmentURLString = content.userInfo["attachment"] as? String,
          let attachmentURL = URL(string: attachmentURLString),
          let imageData = try? Data(contentsOf: attachmentURL) else {
      return nil // This is called in case there is no attachment available
    }

    return try? UNNotificationAttachment(data: imageData,
                                         fileExtension: (attachmentURLString as NSString).pathExtension,
                                         options: nil)
  }
}

// MARK: Override "UNNotificationAttachment" to download the attachment from the given remote URL

extension UNNotificationAttachment {
  convenience init(data: Data, fileExtension: String?, options: [NSObject: AnyObject]?) throws {
    let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
    let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)

    try FileManager.default.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
    let imageFileIdentifier = UUID().uuidString + ".\(fileExtension ?? "jpg")"
    let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
    try data.write(to: fileURL)

    try self.init(identifier: imageFileIdentifier, url: fileURL, options: options)
  }
}
