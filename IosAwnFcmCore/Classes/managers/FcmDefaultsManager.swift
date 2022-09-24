//
//  FcmDefaultsManager.swift
//  awesome_notifications_fcm
//
//  Created by Rafael Setragni on 04/06/21.
//

import Foundation
import IosAwnCore

public class FcmDefaultsManager {
    
    let TAG = "FcmDefaultsManager"
    let userDefaults:UserDefaults = UserDefaults(suiteName: Definitions.USER_DEFAULT_TAG)!
    
    // ************** SINGLETON PATTERN ***********************
    
    static var instance:FcmDefaultsManager?
    public static var shared:FcmDefaultsManager {
        get {
            FcmDefaultsManager.instance =
                FcmDefaultsManager.instance ?? FcmDefaultsManager()
            return FcmDefaultsManager.instance!
        }
    }
    private init(){}
    
    // ********************************************************
        
    public var isFirebaseEnabled:Bool {
        get { return Bool(userDefaults.object(forKey: FcmDefinitions.FIREBASE_ENABLED) as? Bool ?? false) }
        set { userDefaults.setValue(newValue, forKey: FcmDefinitions.FIREBASE_ENABLED) }
    }
    
    public var debug:Bool {
        get { return Bool(userDefaults.object(forKey: FcmDefinitions.DEBUG_MODE) as? Bool ?? false) }
        set { userDefaults.setValue(newValue, forKey: FcmDefinitions.DEBUG_MODE) }
    }
    
    public var silentCallback:Int64 {
        get { return Int64(userDefaults.object(forKey: FcmDefinitions.SILENT_HANDLE) as? Int64 ?? 0) }
        set { userDefaults.setValue(newValue, forKey: FcmDefinitions.SILENT_HANDLE) }
    }
    
    public var backgroundCallback:Int64 {
        get { return Int64(userDefaults.object(forKey: FcmDefinitions.DART_BG_HANDLE) as? Int64 ?? 0) }
        set { userDefaults.setValue(newValue, forKey: FcmDefinitions.DART_BG_HANDLE) }
    }
    
    public var licenseKey:String {
        get { return String(userDefaults.object(forKey: FcmDefinitions.LICENSE_KEY) as? String ?? "") }
        set { userDefaults.setValue(newValue, forKey: FcmDefinitions.LICENSE_KEY) }
    }
}
