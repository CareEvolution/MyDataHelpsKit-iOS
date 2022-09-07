//
//  ExternalAccountsTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 8/25/21.
//

import XCTest
@testable import MyDataHelpsKit

private let accountsJSON = """
    [
        { "id": 100, "status": "fetchComplete", "provider": { "id": 1, "name": "MyDataHelps Demo Provider", "category": "Provider", "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png" }, "lastRefreshDate": "2021-08-01T12:34:56.000Z" }
    ]
    """.data(using: .utf8)!

private let providersJSON = """
    [
        { "id": 1, "name": "MyDataHelps Demo Provider", "category": "Provider", "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png" },
        { "id": 2, "name": "Unknown Category Provider", "category": "NewCategory", "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png" }
    ]
    """.data(using: .utf8)!

class ExternalAccountsTests: XCTestCase {
    func testExternalAccountJSONDecodes() throws {
        let list = try JSONDecoder.myDataHelpsDecoder.decode([ExternalAccount].self, from: accountsJSON)
        XCTAssertEqual(list.count, 1)
        if let first = list.first {
            XCTAssertEqual(first.id.value, 100)
            XCTAssertEqual(first.status, .fetchComplete)
            XCTAssertEqual(first.provider.name, "MyDataHelps Demo Provider")
            XCTAssertEqual(first.provider.logoURL?.absoluteString, "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png")
            XCTAssertNotNil(first.lastRefreshDate)
        }
    }
    
    func testProviderAccountsJSONDecodes() throws {
        let list = try JSONDecoder.myDataHelpsDecoder.decode([ExternalAccountProvider].self, from: providersJSON)
        XCTAssertEqual(list.count, 2)
        if let first = list.first {
            XCTAssertEqual(first.id.value, 1)
            XCTAssertEqual(first.name, "MyDataHelps Demo Provider")
            XCTAssertEqual(first.category, .provider)
            XCTAssertEqual(first.logoURL?.absoluteString, "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png")
        }
        if let last = list.last {
            XCTAssertEqual(last.category, .init(rawValue: "NewCategory"), "Unknown category decodes without error")
        }
    }
}
