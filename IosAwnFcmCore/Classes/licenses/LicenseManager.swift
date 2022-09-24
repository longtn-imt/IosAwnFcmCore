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
        let licenseKey:String = FcmDefaultsManager.shared.licenseKey
        if StringUtils.shared.isNullOrEmpty(licenseKey){
            return false
        }
        
        do {
            let isValidated:Bool = try validateRSASignature(
                packageName: getMainBundle().bundleIdentifier!,
                licenseKey: licenseKey,
                publicKey: Crypto.pemPublicKey,
                signProtocol: .rsaSignatureMessagePKCS1v15SHA256
            )
            return isValidated
        } catch {
            Logger.e(TAG, error.localizedDescription)
            return false
        }
    }
    
    func getMainBundle() -> Bundle {
        var components = Bundle.main.bundleURL.path.split(separator: "/")
        var bundle: Bundle?

        if let index = components.lastIndex(where: { $0.hasSuffix(".app") }) {
            components.removeLast((components.count - 1) - index)
            bundle = Bundle(path: components.joined(separator: "/"))
        }

        return bundle ?? Bundle.main
    }
    
    func validateRSASignature(
        packageName:String,
        licenseKey:String,
        publicKey:String,
        signProtocol:SecKeyAlgorithm
    ) throws -> Bool {
        
        let signedData: Data = packageName.data(using: .utf8)!
        let signature: Data = Data(base64Encoded: licenseKey)!
        let publicKeyData: Data = Data(base64Encoded: Crypto.pemPublicKey, options: [])!
        
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
