//
//  ProjectModelTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 8/11/22.
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
        "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png",
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
        XCTAssertEqual(project.organization.logoURL.absoluteString, "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png")
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
        "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png",
        "color": "#0c509b"
    }
}
""".data(using: .utf8)!
        
        let project = try decoder.decode(ProjectInfo.self, from: json)
        XCTAssertEqual(project.id, projectID)
        XCTAssertEqual(project.name, "Example Project")
        XCTAssertNil(project.description, "description is nil")
        XCTAssertEqual(project.code, "ABCDEF")
        XCTAssertEqual(project.type.rawValue, "Unknown", "Decodes unknown ProjectType without error")
        XCTAssertNil(project.supportEmail, "supportEmail is nil")
        XCTAssertNil(project.supportPhone, "supportPhone is nil")
        XCTAssertNil(project.learnMoreURL, "learnMoreURL is nil")
        XCTAssertNil(project.learnMoreTitle, "learnMoreTitle is nil")
        
        XCTAssertEqual(project.organization.id, organizationID)
        XCTAssertEqual(project.organization.name, "My Organization")
        XCTAssertNil(project.organization.description, "Organization description is nil")
        XCTAssertEqual(project.organization.logoURL.absoluteString, "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png")
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
        "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png",
        "color": "#0c509b"
    },
    "learnMoreLink": ""
}
""".data(using: .utf8)!
        
        let project = try decoder.decode(ProjectInfo.self, from: json)
        XCTAssertNil(project.learnMoreURL)
    }
    
    func testDecodeDataCollectionSettingsWithAllKeysPresent() throws {
        let decoder = JSONDecoder.myDataHelpsDecoder
        let json = """
{
    "fitbitEnabled": true,
    "ehrEnabled": false,
    "airQualityEnabled": true,
    "weatherEnabled": false,
    "queryableDeviceDataTypes": [
        {
            "namespace": "GoogleFit",
            "type": "HeartRate"
        },
        {
            "namespace": "AppleHealth",
            "type": "Steps"
        }
    ],
    "sensorDataCollectionEndDate": "2022-08-11T12:00:00Z"
}
""".data(using: .utf8)!
        
        let settings = try decoder.decode(ProjectDataCollectionSettings.self, from: json)
        XCTAssertTrue(settings.fitbitEnabled, "fitbitEnabled")
        XCTAssertFalse(settings.ehrEnabled, "!ehrEnabled")
        XCTAssertTrue(settings.airQualityEnabled, "airQualityEnabled")
        XCTAssertFalse(settings.weatherEnabled, "!weatherEnabled")
        XCTAssertEqual(settings.queryableDeviceDataTypes.count, 2)
        XCTAssertTrue(settings.queryableDeviceDataTypes.contains(.init(namespace: .googleFit, type: "HeartRate")), "queryableDeviceDataTypes contains HeartRate")
        XCTAssertTrue(settings.queryableDeviceDataTypes.contains(.init(namespace: .appleHealth, type: "Steps")), "queryableDeviceDataTypes contains Steps")
        XCTAssertNotNil(settings.sensorDataCollectionEndDate, "sensorDataCollectionEndDate not nil")
        
        if let sensorDataCollectionEndDate = settings.sensorDataCollectionEndDate {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = .init(secondsFromGMT: 0)!
            XCTAssertTrue(calendar.date(sensorDataCollectionEndDate, matchesComponents: .init(year: 2022, month: 8, day: 11, hour: 12, minute: 0, second: 0)), "sensorDataCollectionEndDate is correct")
        }
    }
}
