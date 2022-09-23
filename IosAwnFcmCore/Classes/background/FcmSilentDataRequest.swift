//
//  SilentData.swift
//  awesome_notifications_fcm
//
//  Created by Rafael Setragni on 08/06/21.
//

import Foundation

public class FcmSilentDataRequest {
    public let silentData: SilentDataModel;
    public let handler: (Bool, Error?) -> ()
    
    init(silentData:SilentDataModel, handler: @escaping (Bool, Error?) -> ()){
        self.silentData = silentData
        self.handler = handler
    }
}
