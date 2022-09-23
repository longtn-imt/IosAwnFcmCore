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
        self.content = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let content = content {            
            _ = fcmService.handleRemoteNotification(
                userInfo: content.userInfo,
                completionHandler: { success, newContent, error in
                    if success {
                        contentHandler(newContent ?? content)
                        return
                    }
                    else {
                        contentHandler(UNNotificationContent())
                        return
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
