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
        { "id": 100, "status": "fetchComplete", "provider": { "id": 1, "name": "RKStudio Demo Provider", "category": "Provider", "logoUrl": "https://careevolution.com/images/rkstudio-logo.png" }, "lastRefreshDate": "2021-08-01T12:34:56.000Z" }
    ]
    """.data(using: .utf8)!

private let providersJSON = """
    [
        { "id": 1, "name": "RKStudio Demo Provider", "category": "Provider", "logoUrl": "https://careevolution.com/images/rkstudio-logo.png" }
    ]
    """.data(using: .utf8)!

class ExternalAccountsTests: XCTestCase {
    func testExternalAccountJSONDecodes() throws {
        let list = try JSONDecoder.myDataHelpsDecoder.decode([ExternalAccount].self, from: accountsJSON)
        XCTAssertEqual(list.count, 1)
        if let first = list.first {
            XCTAssertEqual(first.id, 100)
            XCTAssertEqual(first.status, .fetchComplete)
            XCTAssertEqual(first.provider.name, "RKStudio Demo Provider")
            XCTAssertEqual(first.provider.logoUrl?.absoluteString, "https://careevolution.com/images/rkstudio-logo.png")
            XCTAssertNotNil(first.lastRefreshDate)
        }
    }
    
    func testProviderAccountsJSONDecodes() throws {
        let list = try JSONDecoder.myDataHelpsDecoder.decode([ExternalAccountProvider].self, from: providersJSON)
        XCTAssertEqual(list.count, 1)
        if let first = list.first {
            XCTAssertEqual(first.id, 1)
            XCTAssertEqual(first.category, .provider)
            XCTAssertEqual(first.logoUrl?.absoluteString, "https://careevolution.com/images/rkstudio-logo.png")
        }
    }
}
