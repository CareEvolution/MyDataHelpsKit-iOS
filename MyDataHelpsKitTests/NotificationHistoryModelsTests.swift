//
//  NotificationHistoryModelsTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 3/17/23.
//

import XCTest
@testable import MyDataHelpsKit

final class NotificationHistoryModelsTests: XCTestCase {
    
    func testNotificationHistoryPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(NotificationHistoryPage.self, from: notificationHistoryPageJSON)
        XCTAssertEqual(page.nextPageID, nextPageID1)
        XCTAssertEqual(page.notifications.count, 3)
        
        guard page.notifications.count == 3 else { return }
        
        var item = page.notifications[0]
        XCTAssertEqual(item.id, notificationID1)
        XCTAssertEqual(item.identifier, "SMSExample1")
        XCTAssertEqual(item.sentDate.formatted(.iso8601), "2022-08-10T12:31:36Z")
        XCTAssertEqual(item.statusCode, .succeeded)
        switch item.content {
        case let .sms(content):
            XCTAssertEqual(content?.body, "A sample SMS notification.")
        default:
            XCTFail("Incorrect content for notifications[0]")
        }
        
        item = page.notifications[1]
        XCTAssertEqual(item.id, notificationID2)
        XCTAssertEqual(item.identifier, "PushExample2")
        XCTAssertEqual(item.sentDate.formatted(.iso8601), "2022-06-30T17:16:20Z")
        XCTAssertEqual(item.statusCode, .succeeded)
        switch item.content {
        case let .push(content):
            XCTAssertEqual(content?.title, "Push Title")
            XCTAssertEqual(content?.body, "A sample push notification.")
        default:
            XCTFail("Incorrect content for notifications[1]")
        }
        
        item = page.notifications[2]
        XCTAssertEqual(item.id, notificationID3)
        XCTAssertEqual(item.identifier, "EmailExample3")
        XCTAssertEqual(item.sentDate.formatted(.iso8601), "2022-06-02T14:55:27Z")
        XCTAssertEqual(item.statusCode, .succeeded)
        switch item.content {
        case let .email(content):
            XCTAssertEqual(content?.subject, "A sample email subject line.")
        default:
            XCTFail("Incorrect content for notifications[2]")
        }
    }
    
    func testFailuresNotificationHistoryPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(NotificationHistoryPage.self, from: failuresNotificationHistoryPageJSON)
        XCTAssertNil(page.nextPageID)
        XCTAssertEqual(page.notifications.count, 2)
        
        guard page.notifications.count == 2 else { return }
        
        var item = page.notifications[0]
        XCTAssertEqual(item.id, notificationID1)
        XCTAssertEqual(item.identifier, "SMSExample1")
        XCTAssertEqual(item.sentDate.formatted(.iso8601), "2023-03-17T14:13:42Z")
        XCTAssertEqual(item.statusCode, .missingContactInfo)
        switch item.content {
        case let .sms(content):
            XCTAssertNil(content)
        default:
            XCTFail("Incorrect content for notifications[0]")
        }
        
        item = page.notifications[1]
        XCTAssertEqual(item.id, notificationID3)
        XCTAssertEqual(item.identifier, "EmailExample3")
        XCTAssertEqual(item.sentDate.formatted(.iso8601), "2021-09-22T14:54:13Z")
        XCTAssertEqual(item.statusCode, .unsubscribed)
        switch item.content {
        case let .email(content):
            XCTAssertNil(content)
        default:
            XCTFail("Incorrect content for notifications[1]")
        }
    }
    
    func testEmptyNotificationHistoryPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(NotificationHistoryPage.self, from: emptyNotificationHistoryPageJSON)
        XCTAssertNil(page.nextPageID)
        XCTAssertTrue(page.notifications.isEmpty)
    }
    
    private let nextPageID1 = NotificationHistoryPage.PageID(UUID().uuidString)
    private let notificationID1 = NotificationHistoryModel.ID(UUID().uuidString)
    private let notificationID2 = NotificationHistoryModel.ID(UUID().uuidString)
    private let notificationID3 = NotificationHistoryModel.ID(UUID().uuidString)
    
    private var notificationHistoryPageJSON: Data {
        """
{
  "notifications": [
    {
      "id": "\(notificationID1)",
      "identifier": "SMSExample1",
      "sentDate": "2022-08-10T12:31:36.547+00:00",
      "statusCode": "Succeeded",
      "type": "Sms",
      "content": {
        "body": "A sample SMS notification."
      }
    },
    {
      "id": "\(notificationID2)",
      "identifier": "PushExample2",
      "sentDate": "2022-06-30T17:16:20.52+00:00",
      "statusCode": "Succeeded",
      "type": "Push",
      "content": {
        "title": "Push Title",
        "body": "A sample push notification."
      }
    },
    {
      "id": "\(notificationID3)",
      "identifier": "EmailExample3",
      "sentDate": "2022-06-02T14:55:27.78+00:00",
      "statusCode": "Succeeded",
      "type": "Email",
      "content": {
        "subject": "A sample email subject line."
      }
    }
  ],
  "nextPageID": "\(nextPageID1)"
}
""".data(using: .utf8)! }
    
    private var failuresNotificationHistoryPageJSON: Data {
        """
{
  "notifications": [
    {
      "id": "\(notificationID1)",
      "identifier": "SMSExample1",
      "sentDate": "2023-03-17T14:13:42.383+00:00",
      "statusCode": "MissingContactInfo",
      "type": "Sms",
      "content": null
    },
    {
      "id": "\(notificationID3)",
      "identifier": "EmailExample3",
      "sentDate": "2021-09-22T14:54:13.48+00:00",
      "statusCode": "Unsubscribed",
      "type": "Email",
      "content": null
    }
  ],
  "nextPageID": null
}
""".data(using: .utf8)! }
    
    private var emptyNotificationHistoryPageJSON: Data {
        """
{
  "notifications": [
  ],
  "nextPageID": null
}
""".data(using: .utf8)! }
    
}
