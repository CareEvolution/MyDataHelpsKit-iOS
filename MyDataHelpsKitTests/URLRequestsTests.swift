//
//  URLRequestsTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 3/4/21.
//

import XCTest
@testable import MyDataHelpsKit

class URLRequestsTests: XCTestCase {
    func testCommaDelimitedQueryValue() {
        var sut: Array<String> = []
        XCTAssertNil(sut.commaDelimitedQueryValue, "Empty array")
        
        sut = ["a"]
        XCTAssertEqual(sut.commaDelimitedQueryValue, "a", "Single basic value")
        sut = ["a", "b"]
        XCTAssertEqual(sut.commaDelimitedQueryValue, "a,b", "Two basic values")
        sut = ["a,b"]
        XCTAssertEqual(sut.commaDelimitedQueryValue, "a\\,b", "Single value with comma")
        sut = ["a,b", "c"]
        XCTAssertEqual(sut.commaDelimitedQueryValue, "a\\,b,c", "Multiple values value with comma")
    }
    
    func testDateDecoding() {
        let decoder = JSONDecoder.myDataHelpsDecoder
        let withMS = """
{ "date": "2021-03-11T13:41:00.123+0000" }
""".data(using: .utf8)!
        let modelWithMS: DateModel
        do {
            modelWithMS = try decoder.decode(DateModel.self, from: withMS)
        } catch {
            XCTFail("Encoding date with MS failed \(error)")
            return
        }
        
        let withoutMS = """
{ "date": "2021-03-11T13:41:00+0000" }
""".data(using: .utf8)!
        let modelWithoutMS: DateModel
        do {
            modelWithoutMS = try decoder.decode(DateModel.self, from: withoutMS)
        } catch {
            XCTFail("Encoding date without MS failed \(error)")
            return
        }
        
        XCTAssertEqual(modelWithMS.date.timeIntervalSince(modelWithoutMS.date), 0.123, accuracy: 0.001)
    }
    
    func testDateQueryStringEncoding() {
        let date = DateComponents(calendar: .current, timeZone: .current, year: 2021, month: 2, day: 17, hour: 9, minute: 41, second: 0, nanosecond: 123000000).date!
        
        // e.g. "-0600" or "Z". Matches ISO8601DateFormatter's behavior
        let timeZoneOffset = date.formatted(.dateTime.timeZone(.iso8601(.short)))
        
        XCTAssertEqual(date.queryStringEncoded, "2021-02-17T09:41:00.123\(timeZoneOffset)")
    }
}

fileprivate struct DateModel: Codable {
    static let march11_941am = Date(timeIntervalSince1970: 1615473660.123)
    let date: Date
}
