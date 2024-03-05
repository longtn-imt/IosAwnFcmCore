//
//  LicenseManager.swift
//  awesome_notifications_fcm
//
//  Created by CardaDev on 30/08/22.
//

import Foundation
import IosAwnCore

enum LicenseErrorState {
    case expired
    case singleDoNotMatch
    case withoutValidation
}

final public class LicenseManager {
    let TAG = "LicenseManager"
    let LIB_VERSION = "0.9.0"
    let LIB_DATE = 2024_01_02
    
    var licenseErrorState = LicenseErrorState.withoutValidation
    
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
    
    func isInDebugMode() -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    func splitIntoTwo(_ str: String, separator: String) -> [String] {
        if let range = str.range(of: separator) {
            let firstPart = String(str[..<range.lowerBound])
            let secondPart = String(str[range.upperBound...])
            return [firstPart, secondPart]
        } else {
            return [str]
        }
    }
    
    public func isLicenseKeyValid() throws -> Bool {
        let licenseKeys:[String] = FcmDefaultsManager.shared.licenseKeys
        if licenseKeys.isEmpty { return false }
        
        for licenseKey:String in licenseKeys {
            
            let parts = splitIntoTwo(licenseKey, separator: "==")
            if parts.count <= 1 {
                licenseErrorState = .expired
                continue
            }
            
            var prefix = String(parts[0])
            let base64Encoded = String(parts[1])
            let isSingleVersion = prefix.starts(with: "single::")
            
            if isSingleVersion {
                if !licenseKey.starts(with: "single::" + LIB_VERSION + "==") {
                    licenseErrorState = .singleDoNotMatch
                    continue
                }
                prefix = prefix.replacingOccurrences(of: "single::", with: "")
            }
            
            let packageName = SwiftUtils.getMainBundle().bundleIdentifier!
            do {
                let isValidated:Bool = try validateRSASignature(
                    signaturePrefix: prefix,
                    packageName: packageName,
                    licenseKey: base64Encoded,
                    publicKey: Crypto.pemPublicKey,
                    signProtocol: .rsaSignatureMessagePKCS1v15SHA256
                )
                if isValidated {
                    if isSingleVersion {
                        if LIB_VERSION == prefix { return true }
                        licenseErrorState = .singleDoNotMatch
                    } else {
                        let licenseDate = Int(prefix.replacingOccurrences(of: "-", with: "")) ?? 0
                        if LIB_DATE <= licenseDate + 10_000 { return true }
                        licenseErrorState = .expired
                    }
                }
            } catch {
                Logger.shared.e(TAG, error.localizedDescription)
                Logger.shared.e(TAG, "Invalid license key: \(licenseKey)")
            }
        }
        printLicenseMessageError()
        return isInDebugMode()
    }
    
    var isMessageAlreadyPrinted = false
    func printLicenseMessageError() {
        if isMessageAlreadyPrinted { return }
        isMessageAlreadyPrinted = true
        
        let licenseMessage: String
        let packageName = Bundle.main.bundleIdentifier ?? "Unknown"
        
        switch licenseErrorState {
            case .expired:
                licenseMessage = "WARNING: The current licenses for Awesome Notifications does not cover this FCM plugin release. Please update your license to use the latest version of Awesome Notification's FCM plugin in release mode without watermarks. Application ID: \"\(packageName)\". Version: \(LIB_VERSION). For more information and to update your license, please visit https://awesome-notifications.carda.me#prices."
            case .singleDoNotMatch:
                licenseMessage = "WARNING: Your current single license key does not cover this version of the Awesome Notifications FCM plugin. Please upgrade your license to use this version of the plugin in release mode without limitations. Application ID: \"\(packageName)\". Version: \(LIB_VERSION). For more information and to upgrade your license, please visit https://awesome-notifications.carda.me#prices."
            case .withoutValidation:
                licenseMessage = "You need to insert a valid license key (Year 2) to use Awesome Notification's FCM plugin in release mode without watermarks (application id: \"\(packageName)\"). Version: \(LIB_VERSION). To know more about it, please visit https://awesome-notifications.carda.me#prices."
        }

        let isDebuggable = _isDebugAssertConfiguration()
        
        switch licenseErrorState {
            case .expired, .singleDoNotMatch:
                Logger.shared.w(TAG, licenseMessage)
            case .withoutValidation:
                if isDebuggable {
                    Logger.shared.i(TAG, licenseMessage)
                } else {
                    Logger.shared.e(TAG, licenseMessage)
                }
        }
    }
    
    func validateRSASignature(
        signaturePrefix:String,
        packageName:String,
        licenseKey:String,
        publicKey:String,
        signProtocol:SecKeyAlgorithm
    ) throws -> Bool {
        
        guard let signedData: Data = (signaturePrefix+":"+packageName).data(using: .utf8),
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
