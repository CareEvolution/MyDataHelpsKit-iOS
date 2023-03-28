//
//  ParticipantInfoTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 3/16/23.
//

import XCTest
@testable import MyDataHelpsKit

final class ParticipantInfoTests: XCTestCase {
    func testDecodesParticipantInfoWithOptionalValues() throws {
        let info = try JSONDecoder.myDataHelpsDecoder.decode(ParticipantInfo.self, from: participantInfoMinimumJSON)
        XCTAssertEqual(info.participantID, participantID1)
        XCTAssertEqual(info.projectID, projectID1)
        XCTAssertEqual(info.participantIdentifier, participantIdentifier1)
        XCTAssertNil(info.secondaryIdentifier)
        XCTAssertTrue(info.customFields.isEmpty)
        XCTAssertNil(info.enrollmentDate)
        
        XCTAssertNil(info.demographics.email)
        XCTAssertNil(info.demographics.mobilePhone)
        XCTAssertNil(info.demographics.firstName)
        XCTAssertNil(info.demographics.middleName)
        XCTAssertNil(info.demographics.lastName)
        XCTAssertNil(info.demographics.street1)
        XCTAssertNil(info.demographics.street2)
        XCTAssertNil(info.demographics.city)
        XCTAssertNil(info.demographics.state)
        XCTAssertNil(info.demographics.postalCode)
        XCTAssertNil(info.demographics.dateOfBirth)
        XCTAssertNil(info.demographics.preferredLanguage)
        XCTAssertNil(info.demographics.gender)
        XCTAssertNil(info.demographics.utcOffset)
        XCTAssertNil(info.demographics.timeZone)
        XCTAssertFalse(info.demographics.isUnsubscribedFromEmails)
        XCTAssertFalse(info.demographics.isUnsubscribedFromSMS)
    }
    
    func testDecodesParticipantInfoWithAllValues() throws {
        let info = try JSONDecoder.myDataHelpsDecoder.decode(ParticipantInfo.self, from: participantInfoJSON)
        XCTAssertEqual(info.participantID, participantID2)
        XCTAssertEqual(info.projectID, projectID2)
        XCTAssertEqual(info.participantIdentifier, participantIdentifier2)
        XCTAssertEqual(info.secondaryIdentifier, "secondary-1")
        XCTAssertEqual(info.customFields.count, 2)
        XCTAssertEqual(info.customFields["MOBILE_PHONE"], "(555) 555-1212")
        XCTAssertEqual(info.customFields["INT_BADGE_1"], "5")
        XCTAssertEqual(info.enrollmentDate?.formatted(.iso8601), "2020-05-12T16:50:55Z")
        
        XCTAssertEqual(info.demographics.email, "email@example.com")
        XCTAssertEqual(info.demographics.mobilePhone, "(555) 555-1212")
        XCTAssertEqual(info.demographics.firstName, "FName")
        XCTAssertEqual(info.demographics.middleName, "M")
        XCTAssertEqual(info.demographics.lastName, "LName")
        XCTAssertEqual(info.demographics.street1, "123 Street St")
        XCTAssertEqual(info.demographics.street2, "Apt #1")
        XCTAssertEqual(info.demographics.city, "Anywhere")
        XCTAssertEqual(info.demographics.state, "MI")
        XCTAssertEqual(info.demographics.postalCode, "55555")
        XCTAssertEqual(info.demographics.dateOfBirth, "1999-12-31")
        XCTAssertEqual(info.demographics.preferredLanguage, "es")
        XCTAssertEqual(info.demographics.gender, .other)
        XCTAssertEqual(info.demographics.utcOffset, "-04:00:00")
        XCTAssertEqual(info.demographics.timeZone, "America/New_York")
        XCTAssertTrue(info.demographics.isUnsubscribedFromEmails)
        XCTAssertFalse(info.demographics.isUnsubscribedFromSMS)
    }
    
    private let participantID1 = ParticipantInfo.ID(UUID().uuidString)
    private let participantID2 = ParticipantInfo.ID(UUID().uuidString)
    private let projectID1 = Project.ID(UUID().uuidString)
    private let projectID2 = Project.ID(UUID().uuidString)
    private let participantIdentifier1 = UUID().uuidString
    private let participantIdentifier2 = UUID().uuidString
    
    private var participantInfoMinimumJSON: Data { """
{
  "participantID": "\(participantID1)",
  "participantIdentifier": "\(participantIdentifier1)",
  "secondaryIdentifier": null,
  "demographics": {
  },
  "customFields": {
  },
  "projectID": "\(projectID1)"
}
""".data(using: .utf8)! }
    
    private var participantInfoJSON: Data { """
{
  "participantID": "\(participantID2)",
  "participantIdentifier": "\(participantIdentifier2)",
  "secondaryIdentifier": "secondary-1",
  "demographics": {
    "email": "email@example.com",
    "mobilePhone": "(555) 555-1212",
    "firstName": "FName",
    "middleName": "M",
    "lastName": "LName",
    "street1": "123 Street St",
    "street2": "Apt #1",
    "city": "Anywhere",
    "state": "MI",
    "postalCode": "55555",
    "dateOfBirth": "1999-12-31",
    "preferredLanguage": "es",
    "gender": "O",
    "utcOffset": "-04:00:00",
    "unsubscribedFromEmails": "true",
    "unsubscribedFromSms": "false",
    "timeZone": "America/New_York"
  },
  "customFields": {
    "MOBILE_PHONE": "(555) 555-1212",
    "INT_BADGE_1": "5"
  },
  "enrollmentDate": "2020-05-12T16:50:55.528+00:00",
  "projectID": "\(projectID2)"
}
""".data(using: .utf8)! }
}
