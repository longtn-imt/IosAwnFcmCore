//
//  FcmBackgroundExecutor.swift
//  awesome_notifications_fcm
//
//  Created by CardaDev on 12/04/22.
//

import Foundation

public protocol FcmBackgroundExecutor {
    
    init()
    
    var isRunning:Bool { get }
    var isNotRunning:Bool { get }
        
    func runBackgroundProcess(
        silentDataRequest: FcmSilentDataRequest,
        silentCallbackHandle:Int64,
        dartCallbackHandle:Int64
    )
}
