//
//  FCMService.swift
//  awesome_notifications_fcm
//
//  Created by Rafael Setragni on 03/06/21.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
open class AwesomeServiceExtension: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var content: UNMutableNotificationContent?
    
    var fcmService:AwesomeFcmService = AwesomeFcmService()
    
    open override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ){
        self.contentHandler = contentHandler
        guard var initialContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        else {
            contentHandler(request.content)
            return
        }
        
        self.content = initialContent
        if var _ = content {
            _ = fcmService.executeRemoteInstructions(
                userInfo: initialContent.userInfo,
                contentInProgress: &initialContent,
                executeCompletion: { [self] success, mutableContent, error in
                    let currentContent = mutableContent ?? self.content ?? UNMutableNotificationContent()
                    if success {
                        contentHandler(currentContent)
                        return
                    }
                    else {
                        currentContent.categoryIdentifier = "INVALID"
                        contentHandler(currentContent)
                    }
                })
        }
    }
    
    public override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler {
            let fasterNotification:UNNotificationContent = fcmService.handleRemoteWillExpire()
            contentHandler(fasterNotification)
        }
    }

}
