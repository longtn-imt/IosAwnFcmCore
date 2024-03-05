//
//  JsonFlattenerTest.swift
//  IosAwnFcmCore_Tests
//
//  Created by Rafael Setragni on 23/12/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import IosAwnFcmCore // Replace with your app's module name

class JsonFlattenerTest: XCTestCase {
    
    func testListRow() {
        let unflattenedMap = JsonFlattener.shared.decode(flatMap: ["actionButtons.1.key": "DISMISS"])
        XCTAssertTrue(unflattenedMap.keys.contains("actionButtons"))
        XCTAssertTrue(unflattenedMap["actionButtons"] is [Any])
        if let actionButtons = unflattenedMap["actionButtons"] as? [[String: Any]] {
            let button1 = actionButtons[0]
            XCTAssertEqual(button1["key"] as? String, "DISMISS")
        }
    }

    func testSimpleUnflattener() {
        let flatMap: [String: String] = [
            "content.id": "1",
            "content.badge": "50",
            "content.channelKey": "alerts",
            "content.displayOnForeground": "true",
            "content.notificationLayout": "BigPicture",
            "content.largeIcon": "https://example.com/large-icon.jpg",
            "content.bigPicture": "https://example.com/big-picture.jpg",
            "content.showWhen": "true",
            "content.autoDismissible": "true",
            "content.privacy": "Private",
            "content.payload.secret": "Awesome Notifications Rocks!",
            "actionButtons.0.key": "REDIRECT",
            "actionButtons.0.label": "Redirect",
            "actionButtons.0.autoDismissible": "true",
            "actionButtons.1.key": "DISMISS",
            "actionButtons.1.label": "Dismiss",
            "actionButtons.1.actionType": "DismissAction",
            "actionButtons.1.isDangerousOption": "true",
            "actionButtons.1.autoDismissible": "true"
        ]
        
        let unflattenedMap = JsonFlattener.shared.decode(flatMap: flatMap)

        // Assertions for 'content' map
        XCTAssertTrue(unflattenedMap.keys.contains("content"))
        XCTAssertTrue(unflattenedMap["content"] is [String: Any])
        if let content = unflattenedMap["content"] as? [String: Any] {
            XCTAssertEqual(content["id"] as? Int, 1)
            XCTAssertEqual(content["badge"] as? Int, 50)
            XCTAssertEqual(content["channelKey"] as? String, "alerts")
            XCTAssertEqual(content["displayOnForeground"] as? Bool, true)
            XCTAssertEqual(content["notificationLayout"] as? String, "BigPicture")
            XCTAssertEqual(content["largeIcon"] as? String, "https://example.com/large-icon.jpg")
            XCTAssertEqual(content["bigPicture"] as? String, "https://example.com/big-picture.jpg")
            XCTAssertEqual(content["showWhen"] as? Bool, true)
            XCTAssertEqual(content["autoDismissible"] as? Bool, true)
            XCTAssertEqual(content["privacy"] as? String, "Private")

            // Assertions for 'payload' inside 'content'
            if let payload = content["payload"] as? [String: String] {
                XCTAssertEqual(payload["secret"], "Awesome Notifications Rocks!")
            }
        }

        // Assertions for 'actionButtons' list
        XCTAssertTrue(unflattenedMap.keys.contains("actionButtons"))
        XCTAssertTrue(unflattenedMap["actionButtons"] is [[String: Any]])
        if let actionButtons = unflattenedMap["actionButtons"] as? [[String: Any]] {
            let button1 = actionButtons[0]
            XCTAssertEqual(button1["key"] as? String, "REDIRECT")
            XCTAssertEqual(button1["label"] as? String, "Redirect")
            XCTAssertEqual(button1["autoDismissible"] as? Bool, true)

            let button2 = actionButtons[1]
            XCTAssertEqual(button2["key"] as? String, "DISMISS")
            XCTAssertEqual(button2["label"] as? String, "Dismiss")
            XCTAssertEqual(button2["actionType"] as? String, "DismissAction")
            XCTAssertEqual(button2["isDangerousOption"] as? Bool, true)
            XCTAssertEqual(button2["autoDismissible"] as? Bool, true)
        }
    }
}
