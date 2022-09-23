//
//  SilentData.swift
//  awesome_notifications_fcm
//
//  Created by CardaDev on 12/04/22.
//

import Foundation
import IosAwnCore

public class SilentDataModel: AbstractModel {
    
    public var data:[String:Any?]?
    
    public var createdDate: RealDateTime?
    public var createdSource: NotificationSource?
    public var createdLifeCycle: NotificationLifeCycle?
    
    public func fromMap(arguments: [String:Any?]?) -> AbstractModel? {
        data = data ?? [:]
        
        for (key, value) in arguments! {
            switch (key) {
                
            case Definitions.NOTIFICATION_CREATED_SOURCE:
                self.createdSource =
                    EnumUtils<NotificationSource>.getEnumOrDefault(
                        reference: Definitions.NOTIFICATION_CREATED_SOURCE,
                        arguments: arguments)
                break;
                
            case Definitions.NOTIFICATION_CREATED_LIFECYCLE:
                self.createdLifeCycle =
                    EnumUtils<NotificationLifeCycle>.getEnumOrDefault(
                        reference: Definitions.NOTIFICATION_CREATED_LIFECYCLE,
                        arguments: arguments)
                
            case Definitions.NOTIFICATION_CREATED_DATE:
                self.createdDate =
                    MapUtils<RealDateTime>.getRealDateOrDefault(
                        reference: Definitions.NOTIFICATION_CREATED_DATE,
                        arguments: arguments,
                        defaultTimeZone: RealDateTime.utcTimeZone)
                
            case FcmDefinitions.SILENT_HANDLE:
                continue;
                
            default:
                data![key] = value
            }
        }
        
        return data!.isEmpty ? nil : self
    }
    
    public func registerCreationEvent(
        createdSource: NotificationSource,
        createdLifeCycle: NotificationLifeCycle
    ){
        self.createdSource = createdSource
        self.createdDate = RealDateTime.init(fromTimeZone: RealDateTime.utcTimeZone)
        self.createdLifeCycle = createdLifeCycle
    }
    
    public func toMap() -> [String : Any?] {
        var mapData:[String: Any?] = [:]
        
        if createdSource != nil {mapData[Definitions.NOTIFICATION_CREATED_SOURCE] = self.createdSource?.rawValue}
        if createdDate != nil {mapData[Definitions.NOTIFICATION_CREATED_DATE] = self.createdDate?.description}
        if createdLifeCycle != nil {mapData[Definitions.NOTIFICATION_CREATED_LIFECYCLE] = self.createdLifeCycle?.rawValue}
        
        if self.data != nil {
            mapData.merge(self.data!) { (current, _) in current }
        }
        
        return mapData
    }
    
    public func validate() throws {
    }
}
