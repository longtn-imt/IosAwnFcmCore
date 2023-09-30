//
//  FcmDefinitions.swift
//  awesome_notifications_fcm
//
//  Created by Rafael Setragni on 03/06/21.
//

import Foundation


public enum FcmDefinitions {
    
    public static let  DART_REVERSE_CHANNEL = "AWFcmReverse"

    public static let  CHANNEL_FLUTTER_PLUGIN = "awesome_notifications_fcm"

    public static let  BROADCAST_FCM_TOKEN = "me.carda.awesome_notifications_fcm.services.firebase.TOKEN"
    public static let  BROADCAST_SILENT_DATA = "me.carda.awesome_notifications_fcm.services.silentData"

    public static let  SHARED_FCM_DEFAULTS = "fcmDefaults"
    public static let  LICENSE_KEYS = "licenseKeys"

    public static let  FIREBASE_FLAG_IS_SILENT_DATA = "isSilentData"
    public static let  FIREBASE_ENABLED = "FIREBASE_ENABLED"

    public static let  EXTRA_BROADCAST_FCM_TOKEN = "token"
    public static let  EXTRA_SILENT_DATA = "silentData"

    public static let  DEBUG_MODE = "debug"
    public static let  SILENT_HANDLE = "fcmSilentHandle"
    public static let  DART_BG_HANDLE = "fcmDartBGHandle"

    public static let  NOTIFICATION_TOPIC = "topic"

    public static let  REMAINING_SILENT_DATA = "remainingSilentData"
    public static let  NOTIFICATION_SILENT_DATA = "silentData"

    public static let  CHANNEL_METHOD_INITIALIZE = "initialize"
    public static let  CHANNEL_METHOD_PUSH_NEXT_DATA = "pushNext"
    public static let  CHANNEL_METHOD_GET_FCM_TOKEN = "getFirebaseToken"
    public static let  CHANNEL_METHOD_NEW_FCM_TOKEN = "newFcmToken"
    public static let  CHANNEL_METHOD_NEW_NATIVE_TOKEN = "newNativeToken"
    public static let  CHANNEL_METHOD_IS_FCM_AVAILABLE = "isFirebaseAvailable"
    public static let  CHANNEL_METHOD_SUBSCRIBE_TOPIC = "subscribeTopic"
    public static let  CHANNEL_METHOD_UNSUBSCRIBE_TOPIC = "unsubscribeTopic"
    public static let  CHANNEL_METHOD_DELETE_TOKEN = "deleteToken"
    public static let  CHANNEL_METHOD_SILENCED_CALLBACK = "silentCallbackReference"
    public static let  CHANNEL_METHOD_DART_CALLBACK = "dartCallbackReference"
    public static let  CHANNEL_METHOD_SHUTDOWN_DART = "shutdown"
}
