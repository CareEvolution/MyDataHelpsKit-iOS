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
    {
        "externalAccountProviders": [
            { "id": 1, "name": "MyDataHelps Demo Provider", "category": "Provider", "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png" }
        ],
        "totalExternalAccountProviders": 35
    }
    """.data(using: .utf8)!

class ExternalAccountsTests: XCTestCase {
    func testExternalAccountProvidersQuery() {
        var query = ExternalAccountProvidersQuery()
        XCTAssertEqual(query.pageNumber, ExternalAccountProvidersQuery.firstPageNumber, "Defaults to query for first page")
        XCTAssertEqual(query.limit, ExternalAccountProvidersQuery.defaultLimit, "Uses default limit")
        
        query = ExternalAccountProvidersQuery(search: "search text", category: .provider, limit: 25, pageNumber: 2)
        XCTAssertEqual(query.search, "search text", "Search is correct")
        XCTAssertEqual(query.category, .provider, "Category is correct")
        XCTAssertEqual(query.limit, 25, "Valid limit is correct")
        XCTAssertEqual(query.pageNumber, 2, "Valid page number is correct")
        
        XCTAssertEqual(ExternalAccountProvidersQuery(limit: -10).limit, 1, "Lower bound for limit")
        XCTAssertEqual(ExternalAccountProvidersQuery(limit: 1000).limit, ExternalAccountProvidersQuery.defaultLimit, "Upper bound for limit")
        
        XCTAssertEqual(ExternalAccountProvidersQuery(pageNumber: -1).pageNumber, ExternalAccountProvidersQuery.firstPageNumber, "Lower bound for page number")
        
        query = ExternalAccountProvidersQuery(search: "search text", category: .deviceManufacturer, limit: 2, pageNumber: 0)
        let provider1 = ExternalAccountProvider(id: .init(1), name: "Provider", category: .deviceManufacturer, logoURL: nil)
        let fullResultPage0 = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [provider1, provider1], totalExternalAccountProviders: 5), query: query)
        let fullResultPage1 = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [provider1, provider1], totalExternalAccountProviders: 5), query: ExternalAccountProvidersQuery(search: "search text", category: .deviceManufacturer, limit: 2, pageNumber: 1))
        let partialResultPage = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [provider1], totalExternalAccountProviders: 5), query: query)
        let emptyResultPage = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [], totalExternalAccountProviders: 5), query: query)
        
        let pageAfter = query.page(after: fullResultPage0)
        XCTAssertEqual(pageAfter?.search, "search text", "Copies search to next page query")
        XCTAssertEqual(pageAfter?.category, .deviceManufacturer, "Copies category to next page query")
        XCTAssertEqual(pageAfter?.limit, 2, "Copies limit to next page query")
        XCTAssertEqual(pageAfter?.pageNumber, 1, "Increments page number")
        XCTAssertEqual(pageAfter?.page(after: fullResultPage1)?.pageNumber, 2, "Increments page number again")
        XCTAssertEqual(query.page(after: fullResultPage1)?.pageNumber, 2, "Increments page number based on result's page number, not the original query")
        
        XCTAssertNil(pageAfter?.page(after: partialResultPage), "Partial result indicates end of pages")
        XCTAssertNil(pageAfter?.page(after: emptyResultPage), "Empty result indicates end of pages")
    }
    
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
    
    func testExternalAccountProvidersResultPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(ExternalAccountProvidersResultPage.APIResponse.self, from: providersJSON)
        XCTAssertEqual(page.externalAccountProviders.count, 1)
        XCTAssertEqual(page.totalExternalAccountProviders, 35)
        if let first = page.externalAccountProviders.first {
            XCTAssertEqual(first.id.value, 1)
            XCTAssertEqual(first.name, "MyDataHelps Demo Provider")
            XCTAssertEqual(first.category, .provider)
            XCTAssertEqual(first.logoURL?.absoluteString, "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png")
        }
    }
}
