//
//  AwesomeFcmReceiver.swift
//  awesome_notifications_fcm
//
//  Created by CardaDev on 12/04/22.
//

import Foundation
import IosAwnCore

public class AwesomeFcmEventsReceiver {
    private let TAG = "AwesomeFcmEventsReceiver"
    
    // **************************** SINGLETON PATTERN *************************************
    
    open var debug:Bool = false
    static var instance:AwesomeFcmEventsReceiver?
    public static var shared:AwesomeFcmEventsReceiver {
        get {
            AwesomeFcmEventsReceiver.instance =
                AwesomeFcmEventsReceiver.instance ?? AwesomeFcmEventsReceiver()
            return AwesomeFcmEventsReceiver.instance!
        }
    }
    private init(){}
    
    // **************************** OBSERVER PATTERN **************************************
    
    private lazy var fcmEventListeners = [AwesomeFcmListener]()
    
    public func subscribeOnNotificationEvents(listener:AwesomeFcmListener) -> Self {
        fcmEventListeners.append(listener)
        
        if debug {
            Logger.d(TAG, String(describing: listener) + " subscribed to receive FCM events")
        }
        return self
    }
    
    public func unsubscribeOnNotificationEvents(listener:AwesomeFcmListener) -> Self {
        if let index = fcmEventListeners.firstIndex(where: {$0 === listener}) {
            fcmEventListeners.remove(at: index)
            if debug {
                Logger.d(TAG, String(describing: listener) + " unsubscribed from FCM events")
            }
        }
        return self
    }
    
    public func addNewTokenEvent(
        withToken token:String?
    ){
        if debug && fcmEventListeners.isEmpty {
            Logger.e(TAG, "New FCM token event ignored, as there is no listeners waiting for new notification events")
        }
        
        for listener in fcmEventListeners {
            listener.onNewFcmToken(token: token)
        }
    }
    
    public func addNewNativeTokenEvent(
        withToken token:String?
    ){
        if debug && fcmEventListeners.isEmpty {
            Logger.e(TAG, "New Native token event ignored, as there is no listeners waiting for new notification events")
        }
        
        for listener in fcmEventListeners {
            listener.onNewNativeToken(token: token)
        }
    }
}
