//
//  FCMService.swift
//  awesome_notifications_fcm
//
//  Created by Rafael Setragni on 04/06/21.
//

import Foundation
import IosAwnCore

open class AwesomeFcmService {
        
    let TAG = "AwesomeFcmService"
    
    let contentInProgress:UNMutableNotificationContent = UNMutableNotificationContent()
    var messageId:String?
    var originalTitle:String?
    var originalBody:String?
    var originalBadge:Int?
    var originalImage:String?
    
    public init(){}
    
    public func didReceiveRemoteNotification(
        userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        let start = DispatchTime.now()
        let aps = userInfo["aps"] as? [String: AnyObject]
        if aps?["content-available"] as? Int == 1 {
            return handleSilentData(
                        userInfo: userInfo,
                        source: FcmSource.ReceiveRemote) { [self] success, error in
                            if success {
                                completionHandler(.newData)
                            } else if error == nil {
                                completionHandler(.noData)
                            } else {
                                completionHandler(.failed)
                            }

                            let end = DispatchTime.now()
                            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                            let timeInterval:Double = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
                            Logger.d(TAG, "Background silent push execution finished in \(timeInterval.rounded())ms")
                        }
        } else {
            return handleRemoteNotification(
                    userInfo: userInfo) { [self] success, notificationContent, error in
                        if success {
                            completionHandler(.newData)
                        } else if error == nil {
                            completionHandler(.noData)
                        } else {
                            completionHandler(.failed)
                        }

                        let end = DispatchTime.now()
                        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                        let timeInterval:Double = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
                        Logger.d(TAG, "Remote push notification execution finished in \(timeInterval.rounded())ms")
                    }
        }
    }
    
    func handleRemoteNotification(
        userInfo: [AnyHashable : Any],
        completionHandler: @escaping (Bool, UNNotificationContent?, Error?) -> Void
    ) -> Bool {
        
        DefaultsManager.shared.checkIfAppGroupConnected()
        
        let initialLifeCycle:NotificationLifeCycle = LifeCycleManager.shared.currentLifeCycle
            
        contentInProgress.title = ""
        contentInProgress.body = ""
        contentInProgress.userInfo = userInfo
            
        guard let messageId:String = userInfo["gcm.message_id"] as? String
        else {
            completionHandler(false, contentInProgress, nil)
            return false
        }
            
        Logger.d(TAG, "Received Firebase message id: "+(messageId))
            
        if let aps = userInfo["aps"] as? Dictionary<String, AnyObject> {
            if let alert = aps["alert"]  as? Dictionary<String, AnyObject> {
                originalTitle = alert["title"] as? String
                originalBody  = alert["body"] as? String
            }
            originalBadge  = aps["badge"] as? Int
        }
        
        if let options = userInfo["fcm_options"] as? NSDictionary {
            originalImage = options["image"] as? String
        }
        
        let isSilentData:Bool =
                  StringUtils.shared.isNullOrEmpty(
                        originalTitle,
                        considerWhiteSpaceAsEmpty: false)
                    &&
                  StringUtils.shared.isNullOrEmpty(
                        originalBody,
                        considerWhiteSpaceAsEmpty: false)
            
        if isSilentData {
            completionHandler(false, contentInProgress, nil)
            return false
        }
        
        do {
            try executeNotificationContent(
                userInfo: userInfo,
                initialLifeCycle: initialLifeCycle,
                completion: completionHandler)
            return true
            
        } catch {
            completionHandler( false, contentInProgress, error )
        }
        return false
    }
    
    func handleSilentData(
        userInfo: [AnyHashable : Any],
        source: FcmSource,
        completionHandler: @escaping (Bool, Error?) -> Void
    ) -> Bool {
        let initialLifeCycle:NotificationLifeCycle =
                LifeCycleManager
                    .shared
                    .currentLifeCycle
        
        do {
            guard let messageId:String = userInfo["gcm.message_id"] as? String
            else {
                throw ExceptionFactory
                      .shared
                      .createNewAwesomeException(
                          className: TAG,
                          code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                          message: "message_id was not found in silent push data",
                          detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS + ".handleSilentData.message_id")
            }
            
            Logger.d(TAG, "Received Firebase message id: " + messageId)
            
            guard let dataMap:[String:Any?] = userInfo as? [String:Any?] else {
                throw ExceptionFactory
                        .shared
                        .createNewAwesomeException(
                            className: TAG,
                            code: FcmExceptionCode.CODE_FCM_EXCEPTION,
                            message: "UserInfo could not be converted into data map",
                            detailedCode: FcmExceptionCode.DETAILED_FCM_EXCEPTION+".handleSilentData.userInfo")
            }
            
            guard let silentData:SilentDataModel =
                    SilentDataModel().fromMap(arguments: dataMap) as? SilentDataModel
            else {
                throw ExceptionFactory
                        .shared
                        .createNewAwesomeException(
                            className: TAG,
                            code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                            message: "AwesomeFcmService received a invalid silent data content",
                            detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS + ".handleSilentData.invalid")
            }
            
            silentData.registerCreationEvent(
                    createdSource: .Firebase,
                    createdLifeCycle: initialLifeCycle)
            
            return try FcmBroadcastSender
                    .shared
                    .SendBroadcastSilentData(
                        silentData: silentData,
                        completionHandler: completionHandler)
            
        } catch {
            if error is AwesomeNotificationsException {
                completionHandler(false, error)
                return false
            }
            else {
                completionHandler(
                    false,
                    ExceptionFactory
                        .shared
                        .createNewAwesomeException(
                            className: TAG,
                            code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                            message: "AwesomeFcmService received a invalid silent data content",
                            detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS + ".handleSilentData.invalid"))
                return false
            }
        }
    }
    
    func executeNotificationContent(
        userInfo: [AnyHashable : Any],
        initialLifeCycle:NotificationLifeCycle,
        completion completionHandler: @escaping (Bool, UNNotificationContent?, Error?) -> Void
    ) throws {
        
        let notificationModel:NotificationModel = NotificationModel()
        
        if userInfo[Definitions.NOTIFICATION_MODEL_CONTENT] != nil {
            
            var mapData:[String:Any?] = [:]
            
            mapData[Definitions.NOTIFICATION_MODEL_CONTENT]  = JsonUtils.fromJson(userInfo[Definitions.NOTIFICATION_MODEL_CONTENT] as? String)
            mapData[Definitions.NOTIFICATION_MODEL_SCHEDULE] = JsonUtils.fromJson(userInfo[Definitions.NOTIFICATION_MODEL_SCHEDULE] as? String)
            mapData[Definitions.NOTIFICATION_MODEL_BUTTONS]  = JsonUtils.fromJsonArr(userInfo[Definitions.NOTIFICATION_MODEL_BUTTONS] as? String)
                        
            if (userInfo[Definitions.NOTIFICATION_MODEL_IOS] != nil) {
                let iosCustomData:[String:Any?]? = JsonUtils.fromJson(userInfo[Definitions.NOTIFICATION_MODEL_IOS] as? String)
                if iosCustomData != nil {
                    mapData = MapUtils<[String:Any?]>.deepMerge(mapData, iosCustomData!)
                }
            }
            
            if notificationModel.fromMap(arguments: mapData) == nil {
                throw ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "AwesomeFcmService received a invalid awesome notification content",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".notificationModel.invalid")
            }
            
            originalTitle = notificationModel.content?.title ?? originalTitle
            originalBody = notificationModel.content?.body ?? originalBody
            originalBadge = notificationModel.content?.badge ?? originalBadge
            
        }
        else {
            
            notificationModel.content = NotificationContentModel()
            
            let channelList:[NotificationChannelModel] = ChannelManager.shared.listChannels()
            
            notificationModel.content!.id = -1
            notificationModel.content!.channelKey = channelList.first?.channelKey ?? "basic_channel"
            notificationModel.content!.title = originalTitle
            notificationModel.content!.body = originalBody
            notificationModel.content!.badge = originalBadge
            notificationModel.content!.playSound = true
            
            if !StringUtils.shared.isNullOrEmpty(originalImage) {
                notificationModel.content!.notificationLayout = NotificationLayout.BigPicture
                notificationModel.content!.bigPicture = originalImage
            }
            else {
                notificationModel.content!.notificationLayout = NotificationLayout.Default
            }
        }
        
        Logger.d(TAG, "Push notification received")
        
        do {
            
#if DEBUG   // Debug Mode
            
#else
            let isValid:Bool = try LicenseManager.shared.isLicenseKeyValid()
            if !isValid {
                if !StringUtils.shared.isNullOrEmpty(originalTitle) {
                    originalTitle = "[DEMO] " + originalTitle!
                } else{
                    if StringUtils.shared.isNullOrEmpty(originalBody) {
                        originalBody = "[DEMO] " + originalBody!
                    }
                }
            }
#endif
            
            notificationModel.content!.title = originalTitle
            notificationModel.content!.body = originalBody
            notificationModel.content!.badge = originalBadge
            
            contentInProgress.userInfo[Definitions.NOTIFICATION_MODEL_CONTENT] = notificationModel.toMap()
            
            try NotificationSenderAndScheduler.send(
                createdSource: NotificationSource.Firebase,
                notificationModel: notificationModel,
                content: contentInProgress,
                completion: completionHandler,
                appLifeCycle: LifeCycleManager.shared.currentLifeCycle)
        }
        catch {
            completionHandler(false, UNNotificationContent(), error)
        }
    }
    
    func handleRemoteWillExpire() -> UNNotificationContent {
        return contentInProgress
    }
}
