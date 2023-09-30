//
//  TokenManager.swift
//  IosAwnFcmCore
//
//  Created by Rafael Setragni on 14/03/23.
//

import Foundation
import IosAwnCore
import FirebaseCore
import FirebaseMessaging

public class TokenManager {
    private let TAG = "TokenManager"
    
    // **************************** SINGLETON PATTERN *************************************
    
    open var debug:Bool = false
    static var instance:TokenManager?
    public static var shared:TokenManager {
        get {
            TokenManager.instance =
                TokenManager.instance ?? TokenManager()
            return TokenManager.instance!
        }
    }
    private init(){}
    
    // **************************** OBSERVER PATTERN **************************************
    
    var lastFirebaseDeviceToken:String?
    var lastNativeToken:String?
    
    public func setLastFcmToken (withValue token:String?) {
        if lastFirebaseDeviceToken == token { return }
        
        lastFirebaseDeviceToken = token
        AwesomeFcmEventsReceiver
            .shared
            .addNewFcmTokenEvent(withToken: token)
    }
    
    public func setLastNativeToken (withValue deviceToken:Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        Messaging.messaging().apnsToken = deviceToken
        lastNativeToken = deviceTokenString
        
        AwesomeFcmEventsReceiver
            .shared
            .addNewNativeTokenEvent(withToken: deviceTokenString)
    }
    
    
    public func didReceiveRegistrationToken(_ messaging: Messaging, token: String){
        Logger.shared.d(TAG, "Received a new valid token")
        lastFirebaseDeviceToken = token

        AwesomeFcmEventsReceiver
            .shared
            .addNewFcmTokenEvent(withToken: token)
    }
    
    var pendingRequestCompletion: (() -> ())?
    var nativeApnsArived = false
    
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        nativeApnsArived = true
        setLastNativeToken(withValue: deviceToken)
        Logger.shared.d(TAG, "Received a new valid APNs token")
        
        if pendingRequestCompletion != nil {
            var requestCompletion = pendingRequestCompletion
            pendingRequestCompletion = nil
            requestCompletion?()
        }
    }
    
    public func requestNewFcmToken(
        whenFinished requestCompletion: @escaping (String?, AwesomeNotificationsException?) -> ()
    ){
        pendingRequestCompletion = { [self] in
            if let token = lastFirebaseDeviceToken {
                requestCompletion(token, nil)
                setLastFcmToken(withValue: token)
                return
            } else {
                Messaging.messaging().token(completion: { [self] token, error in
                    let success = error == nil

                    Logger.shared.d(TAG,
                             success ?
                                 "Received a new valid FCM token" :
                                 "Fcm token registering failed")
                    
                    setLastFcmToken(withValue: token)

                    if !success {
                        let awesomeException = ExceptionFactory
                            .shared
                            .createNewAwesomeException(
                                className: TAG,
                                code: FcmExceptionCode.CODE_FCM_EXCEPTION,
                                message: error!.localizedDescription,
                                detailedCode: FcmExceptionCode.DETAILED_FCM_EXCEPTION+".request.token",
                                exception: error!
                            )

                        requestCompletion(token, awesomeException)
                    } else {
                        requestCompletion(token, nil)
                    }
                })
            }
        }
    
        if !nativeApnsArived {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                if pendingRequestCompletion == nil {
                    return
                }
                
                if !nativeApnsArived {
                    requestCompletion(nil, nil)
                    return
                }
                
                pendingRequestCompletion?()
            }
        } else {
            pendingRequestCompletion?()
        }
    }
    
    public func deleteToken(
        whenFinished tokenDeletionCompletion: @escaping (Bool, AwesomeNotificationsException?) -> ()
    ) {
        Messaging.messaging().deleteToken { [self] error in
            let success:Bool = error == nil
            Logger.shared.d(TAG,
                     success ?
                         "Token and all subscriptions deleted" :
                         "Token deletion failed")

            if success {
                setLastFcmToken(withValue: nil)
                tokenDeletionCompletion(success, nil)
            } else {
                let awesomeException = ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: TAG,
                        code: FcmExceptionCode.CODE_FCM_EXCEPTION,
                        message: error!.localizedDescription,
                        detailedCode: FcmExceptionCode.DETAILED_FCM_EXCEPTION+".deleteToken",
                        exception: error!)

                tokenDeletionCompletion(success, awesomeException)
            }
        }
    }
    
}
