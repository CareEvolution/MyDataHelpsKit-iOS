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
            { "id": 1, "name": "MyDataHelps Demo Provider", "category": "Provider", "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png" },
            { "id": 2, "name": "Unknown Category Provider", "category": "NewCategory", "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png" }
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
    }
    
    /// Total results 5, limit 2, expect 3 pages, with page indexes 0 through 2.
    func testExternalAccountProvidersQueryPageAfter() {
        let makeProviderQuery: (Int) -> ExternalAccountProvidersQuery = { pageNumber in
                .init(search: "search text", category: .deviceManufacturer, limit: 2, pageNumber: pageNumber)
        }
        
        let query0 = makeProviderQuery(0)
        let provider1 = ExternalAccountProvider(id: .init(1), name: "Provider", category: .deviceManufacturer, logoURL: nil)
        let fullResultPage0 = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [provider1, provider1], totalExternalAccountProviders: 5), query: query0)
        let fullResultPage1 = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [provider1, provider1], totalExternalAccountProviders: 5), query: makeProviderQuery(1))
        let partialResultPage = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [provider1], totalExternalAccountProviders: 5), query: makeProviderQuery(2))
        let emptyResultPage = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [], totalExternalAccountProviders: 5), query: makeProviderQuery(3))
        let emptyResultPage13 = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [], totalExternalAccountProviders: 5), query: makeProviderQuery(13))
        
        let query1 = query0.page(after: fullResultPage0)
        XCTAssertEqual(query1?.search, "search text", "Copies search to next page query")
        XCTAssertEqual(query1?.category, .deviceManufacturer, "Copies category to next page query")
        XCTAssertEqual(query1?.limit, 2, "Copies limit to next page query")
        XCTAssertEqual(query1?.pageNumber, 1, "Increments page number")
        
        XCTAssertEqual(query1?.page(after: fullResultPage1)?.pageNumber, 2, "Increments page number again")
        XCTAssertEqual(query0.page(after: fullResultPage1)?.pageNumber, 2, "Increments page number based on result's page number, not the original query")
        
        XCTAssertNil(query0.page(after: partialResultPage), "Partial result indicates end of pages")
        XCTAssertNil(query0.page(after: emptyResultPage), "Empty result indicates end of pages")
        XCTAssertNil(query0.page(after: emptyResultPage13), "Farther out of page bounds")
        
        let noResults = ExternalAccountProvidersResultPage(result: .init(externalAccountProviders: [], totalExternalAccountProviders: 0), query: query0)
        XCTAssertNil(query0.page(after: noResults), "Test totally empty results")
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
        XCTAssertEqual(page.externalAccountProviders.count, 2)
        XCTAssertEqual(page.totalExternalAccountProviders, 35)
        if let first = page.externalAccountProviders.first {
            XCTAssertEqual(first.id.value, 1)
            XCTAssertEqual(first.name, "MyDataHelps Demo Provider")
            XCTAssertEqual(first.category, .provider)
            XCTAssertEqual(first.logoURL?.absoluteString, "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png")
        }
        if let last = page.externalAccountProviders.last {
            XCTAssertEqual(last.category, .init(rawValue: "NewCategory"), "Unknown category decodes without error")
        }
    }
}
