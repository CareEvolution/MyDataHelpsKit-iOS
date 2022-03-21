//
//  APIRateLimitTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 3/2/22.
//

import XCTest
@testable import MyDataHelpsKit

class APIRateLimitTests: XCTestCase {
    func testInit() {
        let url = MyDataHelpsClient().baseURL
        var response = HTTPURLResponse(url: url, statusCode: 429, httpVersion: "HTTP/1.1", headerFields: [:])!
        
        XCTAssertNil(APIRateLimit(response: response), "Returns nil when expected headers are missing")
        
        response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [
            "RateLimit-Limit": "789",
            "RateLimit-Remaining": "321",
            "RateLimit-Reset": "20"
        ])!
        
        var limit = APIRateLimit(response: response)
        var expectedReset = Date().addingTimeInterval(20)
        XCTAssertNotNil(limit, "Parsed limit info from valid headers")
        if let limit = limit {
            XCTAssertEqual(limit.maxRequestsPerHour, 789)
            XCTAssertEqual(limit.remainingRequests, 321)
            XCTAssertEqual(limit.nextReset.timeIntervalSince(expectedReset), 0, accuracy: 1)
        }
        
        response = HTTPURLResponse(url: url, statusCode: 429, httpVersion: "HTTP/1.1", headerFields: [
            "ratelimit-limit": "1337",
            "ratelimit-remaining": "0",
            "ratelimit-reset": "200"
        ])!
        
        limit = APIRateLimit(response: response)
        expectedReset = Date().addingTimeInterval(200)
        XCTAssertNotNil(limit, "Parsed limit info from case-insensitive headers")
        if let limit = limit {
            XCTAssertEqual(limit.maxRequestsPerHour, 1337)
            XCTAssertEqual(limit.remainingRequests, 0)
            XCTAssertEqual(limit.nextReset.timeIntervalSince(expectedReset), 0, accuracy: 1)
        }
        
        response = HTTPURLResponse(url: url, statusCode: 429, httpVersion: "HTTP/1.1", headerFields: [
            "RateLimit-Limit": "bogus",
            "RateLimit-Remaining": "bogus",
            "RateLimit-Reset": "bogus"
        ])!
        XCTAssertNil(APIRateLimit(response: response), "Returns nil with invalid headers")
    }
}
