//
//  ScopedIdentifierTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 8/17/22.
//

import XCTest
@testable import MyDataHelpsKit

class ScopedIdentifierTests: XCTestCase {
    private struct ExampleModel: Identifiable, Codable {
        typealias ID = ScopedIdentifier<ExampleModel, String>
        
        let id: ID
        let value: String
    }

    private struct BasicModel: Decodable {
        let id: String
        let value: String
    }
    
    private let id100 = ExampleModel.ID("100")
    private let model100 = ExampleModel(id: .init("100"), value: "Value100")
    private let model200 = ExampleModel(id: .init("200"), value: "Value200")
    
    func testHashableEquatable() {
        XCTAssertEqual(id100, id100, "Equatable protocol: identity relation")
        XCTAssertEqual(id100, model100.id, "Equatable protocol: two equal values")
        XCTAssertEqual(id100.hashValue, model100.id.hashValue, "Hashable protocol")
        XCTAssertEqual(model100.value, "Value100", "value")
        XCTAssertNotEqual(model200.id, model100.id, "Equatable: two unequal values")
    }
    
    func testCodable() throws {
        let json = """
{
    "id": "100",
    "value": "100Decoded"
}
""".data(using: .utf8)!
        
        let decoded100 = try JSONDecoder.myDataHelpsDecoder.decode(ExampleModel.self, from: json)
        XCTAssertEqual(decoded100.id, id100, "ScopedIdentifier automatically decodes")
        XCTAssertEqual(decoded100.value, "100Decoded", "doesn't interfere with decoding other model properties")
        
        let data = try JSONEncoder.myDataHelpsEncoder.encode(model200)
        
        // BasicModel has same structure but doesn't use ScopedIdentifier. Encoding/decoding should work identically.
        let decodedCopy = try JSONDecoder.myDataHelpsDecoder.decode(BasicModel.self, from: data)
        XCTAssertEqual(decodedCopy.id, model200.id.value, "Encodes id correctly")
        XCTAssertEqual(decodedCopy.value, model200.value, "Encodes value correctly")
    }
}
