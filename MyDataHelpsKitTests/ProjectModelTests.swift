//
//  ProjectModelTests.swift
//  MyDataHelpsKitTests
//
//  Created by Mike Mertsock on 8/11/22.
//

import XCTest
@testable import MyDataHelpsKit

class ProjectModelTests: XCTestCase {
    func testDecodeProjectInfoWithAllKeysPresent() throws {
        let decoder = JSONDecoder.myDataHelpsDecoder
        
        let projectID = UUID().uuidString
        let organizationID = UUID().uuidString
        let json = """
{
    "id": "\(projectID)",
    "name": "Example Project",
    "description": "Project description",
    "code": "ABCDEF",
    "type": "Research Study",
    "organization": {
        "id": "\(organizationID)",
        "name": "My Organization",
        "description": "Organization description",
        "logoUrl": "https://careevolution.com/images/rkstudio-logo.png",
        "color": "#0c509b"
    },
    "supportEmail": "support@example.com",
    "supportPhone": "(555) 555-1212",
    "learnMoreLink": "https://example.com/",
    "learnMoreTitle": "Learn More"
}
""".data(using: .utf8)!
        
        let project = try decoder.decode(ProjectInfo.self, from: json)
        XCTAssertEqual(project.id, projectID)
        XCTAssertEqual(project.name, "Example Project")
        XCTAssertEqual(project.description, "Project description")
        XCTAssertEqual(project.code, "ABCDEF")
        XCTAssertEqual(project.type, .researchStudy)
        XCTAssertEqual(project.supportEmail, "support@example.com")
        XCTAssertEqual(project.supportPhone, "(555) 555-1212")
        XCTAssertEqual(project.learnMoreURL?.absoluteString, "https://example.com/")
        XCTAssertEqual(project.learnMoreTitle, "Learn More")
        
        XCTAssertEqual(project.organization.id, organizationID)
        XCTAssertEqual(project.organization.name, "My Organization")
        XCTAssertEqual(project.organization.description, "Organization description")
        XCTAssertEqual(project.organization.logoURL.absoluteString, "https://careevolution.com/images/rkstudio-logo.png")
        XCTAssertEqual(project.organization.color, "#0c509b")
    }
    
    func testDecodeProjectInfoWithOptionalValues() throws {
        let decoder = JSONDecoder.myDataHelpsDecoder
        
        let projectID = UUID().uuidString
        let organizationID = UUID().uuidString
        let json = """
{
    "id": "\(projectID)",
    "name": "Example Project",
    "code": "ABCDEF",
    "type": "Unknown",
    "organization": {
        "id": "\(organizationID)",
        "name": "My Organization",
        "logoUrl": "https://careevolution.com/images/rkstudio-logo.png",
        "color": "#0c509b"
    }
}
""".data(using: .utf8)!
        
        let project = try decoder.decode(ProjectInfo.self, from: json)
        XCTAssertEqual(project.id, projectID)
        XCTAssertEqual(project.name, "Example Project")
        XCTAssertNil(project.description, "description is nil")
        XCTAssertEqual(project.code, "ABCDEF")
        XCTAssertEqual(project.type.rawValue, "Unknown")
        XCTAssertNil(project.supportEmail, "supportEmail is nil")
        XCTAssertNil(project.supportPhone, "supportPhone is nil")
        XCTAssertNil(project.learnMoreURL, "learnMoreURL is nil")
        XCTAssertNil(project.learnMoreTitle, "learnMoreTitle is nil")
        
        XCTAssertEqual(project.organization.id, organizationID)
        XCTAssertEqual(project.organization.name, "My Organization")
        XCTAssertNil(project.organization.description, "Organization description is nil")
        XCTAssertEqual(project.organization.logoURL.absoluteString, "https://careevolution.com/images/rkstudio-logo.png")
        XCTAssertEqual(project.organization.color, "#0c509b")
    }
    
    func testDecodeProjectInfoWithEmptyStringURL() throws {
        let decoder = JSONDecoder.myDataHelpsDecoder
        
        let projectID = UUID().uuidString
        let organizationID = UUID().uuidString
        let json = """
{
    "id": "\(projectID)",
    "name": "Example Project",
    "code": "ABCDEF",
    "type": "Unknown",
    "organization": {
        "id": "\(organizationID)",
        "name": "My Organization",
        "logoUrl": "https://careevolution.com/images/rkstudio-logo.png",
        "color": "#0c509b"
    },
    "learnMoreLink": ""
}
""".data(using: .utf8)!
        
        let project = try decoder.decode(ProjectInfo.self, from: json)
        XCTAssertNil(project.learnMoreURL)
    }
}
