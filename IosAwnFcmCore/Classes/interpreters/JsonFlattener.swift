//
//  JsonFlattener.swift
//  IosAwnFcmCore
//
//  Created by Rafael Setragni on 17/12/23.
//

import Foundation
import IosAwnCore

class JsonFlattener {
    
    // ************** SINGLETON PATTERN ***********************
    
    static var instance:JsonFlattener?
    public static var shared:JsonFlattener {
        get {
            JsonFlattener.instance = JsonFlattener.instance ?? JsonFlattener()
            return JsonFlattener.instance!
        }
    }
    private init(){}
    
    // ************** FACTORY METHODS ***********************
    
    private func allKeysAreNumeric(_ dict: [String: Any]) -> Bool {
        return dict.keys.allSatisfy { key in Int(key) != nil }
    }

    private func convertDictToArray(_ dict: [String: Any]) -> [Any?] {
        let sortedKeys = dict.keys.compactMap(Int.init).sorted()
        return sortedKeys.map { dict[String($0)] }
    }
    
    private func transformStructure(_ structure: Any) -> Any {
        if let dict = structure as? [String: Any] {
            if allKeysAreNumeric(dict) {
                return convertDictToArray(dict)
            } else {
                var newDict = [String: Any]()
                for (key, value) in dict {
                    newDict[key] = transformStructure(value)
                }
                return newDict
            }
        } else if let array = structure as? [Any] {
            return array.map(transformStructure)
        } else {
            return structure
        }
    }


    
    private func updateStructure(keys: [String], value: String, currentStructure: inout [String:Any], currentIndex: Int) -> [String:Any] {
        let key = keys[currentIndex]
        if currentIndex == keys.count - 1 {
            currentStructure[key] = convertToProperValue(value)
        } else {
            var nextStructure = currentStructure[key] as? [String:Any] ?? [String:Any]()
            currentStructure[key] = updateStructure(
                keys:keys,
                value:value,
                currentStructure:&nextStructure,
                currentIndex:currentIndex + 1
            )
        }
        return currentStructure
    }

    func convertToProperValue(_ value: String) -> Any {
        if let intValue = Int(value) {
            return intValue
        } else if let boolValue = Bool(value) {
            return boolValue
        }
        return value
    }
    
    func decode(flatMap: [AnyHashable: Any]) -> [String:Any] {
        var unflattenedMap = [String: Any]()

        for (key, value) in flatMap {
            guard let value = value as? String else { continue }
            guard let key = key as? String else { continue }
            let keys:[String] = key.split(separator: ".").map(String.init)
            unflattenedMap = updateStructure(
                keys:keys,
                value:value,
                currentStructure:&unflattenedMap,
                currentIndex:0)
        }
        
        return transformStructure(unflattenedMap) as? [String: Any] ?? [:]
    }
}
