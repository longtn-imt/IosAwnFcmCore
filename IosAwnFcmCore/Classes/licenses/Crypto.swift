//
//  Crypto.swift
//  awesome_notifications_fcm
//
//  Created by CardaDev on 30/08/22.
//

import Foundation

public class Crypto {
    public static let signProtocol:SecKeyAlgorithm = .rsaSignatureDigestPKCS1v15SHA256
    public static let pemPublicKey =
        "MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgFf9hnX01Ey13U22dcPIbvkvEbF8" +
        "6dxGDWFpp67x6/HdAmCEYCRKD0VgiZy53TOU9byI1KGECeneEAkdinY8GvxOtoJ0" +
        "9OWQOR+0/2IDY7DrsXiw9n0Fm1kEGVzzD5EubglhOdg7yFpoF1iN7hpFja2BBldp" +
        "XSnFAPBN0uAgiBdZAgMBAAE="
}
