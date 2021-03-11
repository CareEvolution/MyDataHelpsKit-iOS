//
//  MyDataHelpsClientTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 3/4/21.
//

import XCTest
@testable import MyDataHelpsKit

class MyDataHelpsClientTests: XCTestCase {
    func testDefaultBaseURL() {
        let sut = MyDataHelpsClient()
        // Detect accidental base URL changes
        XCTAssertEqual(sut.baseURL.absoluteString, "https://rkstudio.careevolution.com/ppt/")
    }
    
    func testEndpoint() {
        let sut = MyDataHelpsClient()
        let url = sut.endpoint(path: "example")
        // Detect accidental base URL changes
        XCTAssertEqual(url.absoluteString, "https://rkstudio.careevolution.com/ppt/example")
    }
    
    func testEndpointWithQueryItems() {
        let sut = MyDataHelpsClient()
        var url = try? sut.endpoint(path: "example", queryItems: [])
        XCTAssertNotNil(url)
        if let urlString = url?.absoluteString {
            XCTAssertEqual(urlString, "https://rkstudio.careevolution.com/ppt/example?")
        }
        
        url = try? sut.endpoint(path: "example/path", queryItems: [.init(name: "a", value: "b")])
        if let urlString = url?.absoluteString {
            XCTAssertEqual(urlString, "https://rkstudio.careevolution.com/ppt/example/path?a=b")
        }
    }
}
