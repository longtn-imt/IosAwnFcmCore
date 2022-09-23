//
//  AwesomeFcmListener.swift
//  awesome_notifications_fcm
//
//  Created by CardaDev on 12/04/22.
//

import Foundation

public protocol AwesomeFcmListener: AnyObject {
    func onNewFcmToken(token:String?);
    func onNewNativeToken(token:String?);
}
