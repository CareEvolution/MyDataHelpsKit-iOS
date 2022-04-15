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
        XCTAssertEqual(sut.baseURL.absoluteString, "https://mydatahelps.org/", "Default client uses correct base URL")
    }
    
    func testEndpoint() {
        var sut = MyDataHelpsClient()
        var url = sut.endpoint(path: "example/path/1")
        XCTAssertEqual(url.absoluteString, "https://mydatahelps.org/example/path/1", "Default client uses correct base URL in endpoint URLs")
        
        sut = MyDataHelpsClient(baseURL: URL(string: "https://example.com/api/")!)
        url = sut.endpoint(path: "example/path/2")
        XCTAssertEqual(sut.baseURL.absoluteString, "https://example.com/api/", "Custom base URL")
        XCTAssertEqual(url.absoluteString, "https://example.com/api/example/path/2", "Endpoint with custom base URL")
    }
    
    func testEndpointWithQueryItems() {
        let sut = MyDataHelpsClient()
        var url = try? sut.endpoint(path: "example", queryItems: [])
        XCTAssertEqual(url?.absoluteString, "https://mydatahelps.org/example?")
        
        url = try? sut.endpoint(path: "example/path", queryItems: [.init(name: "a", value: "b")])
        XCTAssertEqual(url?.absoluteString, "https://mydatahelps.org/example/path?a=b")
    }
    
    func testEmbeddableURLs() {
        let sut = MyDataHelpsClient()
        let participantLinkID = UUID().uuidString
        let surveyName = UUID().uuidString
        let taskLinkID = UUID().uuidString
        let languageTag = sut.languageTag
        var url = try? sut.embeddableSurveyURL(surveyName: surveyName, participantLinkIdentifier: participantLinkID).get()
        XCTAssertEqual(url?.absoluteString, "https://mydatahelps.org/mydatahelps/\(participantLinkID)/surveylink/\(surveyName)?lang=\(languageTag)")
        url = try? sut.embeddableSurveyURL(taskLinkIdentifier: taskLinkID, participantLinkIdentifier: participantLinkID).get()
        XCTAssertEqual(url?.absoluteString, "https://mydatahelps.org/mydatahelps/\(participantLinkID)/tasklink/\(taskLinkID)?lang=\(languageTag)")
    }
}
