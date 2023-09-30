//
//  LicenseManager.swift
//  awesome_notifications_fcm
//
//  Created by CardaDev on 30/08/22.
//

import Foundation
import IosAwnCore

final public class LicenseManager {
    let TAG = "LicenseManager"
    let APP_VERSION = "0.7.5-pre.1"
    
    // ************** SINGLETON PATTERN ***********************
    
    static var instance:LicenseManager?
    public static var shared:LicenseManager {
        get {
            LicenseManager.instance = LicenseManager.instance ?? LicenseManager()
            return LicenseManager.instance!
        }
    }
    init(){}

    // ********************************************************
        
    public func isLicenseKeyValid() throws -> Bool {
        let licenseKeys:[String] = FcmDefaultsManager.shared.licenseKeys
        if licenseKeys.isEmpty {
            return false
        }
        
        for licenseKey:String in licenseKeys {
            
            var isSingleVersion:Bool = false
            var base64Encoded:String? = nil
            if licenseKey.starts(with: "single:") {
                isSingleVersion = true
                if !licenseKey.starts(with: "single:"+APP_VERSION+":") {
                    continue
                }
                let regex = try! NSRegularExpression(pattern: "single:[\\w\\.\\+]+:", options: [])
                let range = NSRange(location: 0, length: licenseKey.utf16.count)
                base64Encoded = regex
                    .stringByReplacingMatches(
                        in: licenseKey,
                        options: [],
                        range: range,
                        withTemplate: "")
                
            } else {
                base64Encoded = licenseKey
            }
            
            do {
                let isValidated:Bool = try validateRSASignature(
                    packageName:
                        (isSingleVersion ? APP_VERSION+":" : "") +
                        SwiftUtils.getMainBundle().bundleIdentifier!,
                    licenseKey: base64Encoded!,
                    publicKey: Crypto.pemPublicKey,
                    signProtocol: .rsaSignatureMessagePKCS1v15SHA256
                )
                if isValidated { return true }
            } catch {
                Logger.shared.e(TAG, error.localizedDescription)
                Logger.shared.e(TAG, "Invalid license key: \(licenseKey)")
            }
        }
        printLicenseMessageError()
        return false
    }
    
    public func printValidationTest() throws -> Bool {
        if try !isLicenseKeyValid() {
            return false
        }
        else {
            Logger.shared.d(TAG,"Awesome Notification's license key validated")
            return true
        }
    }
    
    func printLicenseMessageError() {
        Logger.shared.i(TAG,
             "You need to insert a valid license key to use Awesome Notification's FCM " +
                 "plugin in release mode without watermarks (Bundle ID: \"\(SwiftUtils.getMainBundle().bundleIdentifier ?? "")\"). " +
             "To know more about it, please visit https://www.awesome-notifications.carda.me#prices")
    }
    
    func validateRSASignature(
        packageName:String,
        licenseKey:String,
        publicKey:String,
        signProtocol:SecKeyAlgorithm
    ) throws -> Bool {
        
        guard let signedData: Data = packageName.data(using: .utf8),
              let signature: Data = Data(base64Encoded: licenseKey),
              let publicKeyData: Data = Data(base64Encoded: Crypto.pemPublicKey, options: [])
        else {
            return false
        }
        
        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(
            publicKeyData as CFData,
            [
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits as String: 1024
            ] as CFDictionary,
            &error
        ) else {
            throw error!.takeRetainedValue() as Error
        }

        // Verify the RSA signature.
        let valid:Bool =
            SecKeyVerifySignature(
                publicKey,
                signProtocol,
                signedData as NSData,
                signature as NSData,
                nil)
        
        return valid
    }
}
