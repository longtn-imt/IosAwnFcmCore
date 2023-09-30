//
//  FcmBackgroundService.swift
//  awesome_notifications
//
//  Created by CardaDev on 25/04/22.
//

import Foundation
import IosAwnCore

open class FcmBackgroundService {
    
    let TAG = "FcmBackgroundService"
    
    public static var backgroundFcmClassType:FcmBackgroundExecutor.Type?
    
    // ************** SINGLETON PATTERN ***********************
    
    static var instance:FcmBackgroundService?
    public static var shared:FcmBackgroundService {
        get {
            FcmBackgroundService.instance =
            FcmBackgroundService.instance ?? FcmBackgroundService()
            return FcmBackgroundService.instance!
        }
    }
    private init(){}
    
    // ********************************************************
    
    public func enqueue(
        silentRequest: FcmSilentDataRequest
    ) throws -> Bool {
        Logger.shared.d(TAG, "A new Dart background service has started")
        
        let backgroundCallback:Int64 = FcmDefaultsManager.shared.backgroundCallback
        let silentCallback:Int64 = FcmDefaultsManager.shared.silentCallback
        
        if backgroundCallback == 0 {
            throw ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "A background message could not be handled in Dart because there is no valid background handler registered",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS + ".enqueue.backgroundCallback")
        }
        
        if silentCallback == 0 {
            throw ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "A background message could not be handled in Dart because there is no valid silent callback handler registered",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS + ".enqueue.silentCallback")
        }
        
        if Thread.isMainThread {
            mainThreadServiceExecution(
                silentRequest: silentRequest,
                backgroundCallback: backgroundCallback,
                silentCallback: silentCallback)
        }
        else {
            try backgroundThreadServiceExecution(
                silentRequest: silentRequest,
                backgroundCallback: backgroundCallback,
                silentCallback: silentCallback)
        }
        
        return true
    }
    
    func mainThreadServiceExecution(
        silentRequest: FcmSilentDataRequest,
        backgroundCallback:Int64,
        silentCallback:Int64
    ){
        // Unfortunately, dart engine only runs in main thread
        
        let fcmBackgroundExecutor:FcmBackgroundExecutor =
        FcmBackgroundService.backgroundFcmClassType!.init()
        
        fcmBackgroundExecutor
            .runBackgroundProcess(
                silentDataRequest: silentRequest,
                silentCallbackHandle: silentCallback,
                dartCallbackHandle: backgroundCallback)
    }
    
    func backgroundThreadServiceExecution(
        silentRequest: FcmSilentDataRequest,
        backgroundCallback:Int64,
        silentCallback:Int64
    ) throws {
        let group = DispatchGroup()
        group.enter()
        
        let workItem:DispatchWorkItem = DispatchWorkItem {
            DispatchQueue.global(qos: .background).async {
                
                let fcmBackgroundExecutor:FcmBackgroundExecutor =
                FcmBackgroundService.backgroundFcmClassType!.init()
                
                fcmBackgroundExecutor
                    .runBackgroundProcess(
                        silentDataRequest: silentRequest,
                        silentCallbackHandle: silentCallback,
                        dartCallbackHandle: backgroundCallback)
            }
            
        }
        
        workItem.perform()
        if group.wait(timeout: DispatchTime.now() + .seconds(10)) == .timedOut {
            workItem.cancel()
            throw ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Background silent push service reached timeout limit",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS + ".backgroundThreadServiceExecution.timeout")
        }
        else {
            silentRequest.handler(true, nil)
        }
    }
    
}
