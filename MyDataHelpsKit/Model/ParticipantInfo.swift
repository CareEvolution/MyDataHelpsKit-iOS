//
//  ParticipantInfo.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

/// Information about a participant.
public struct ParticipantInfo: Decodable {
    /// Auto-generated internal ID for the participant.
    public let participantID: String
    /// Auto-generated internal ID for the project.
    public let projectID: String
    /// Project-specific participant identifier.
    public let participantIdentifier: String
    /// Project-specific secondary identifier.
    public let secondaryIdentifier: String?
    /// Auto-generated identifier used to complete surveys via link, if that feature is enabled for the project.
    public let linkIdentifier: String?
    /// All demographic fields populated for the participant. Unpopulated values are `nil`.
    public let demographics: ParticipantDemographics
    /// Key/value pairs representing project-specific custom fields.
    public let customFields: [String: String]
    /// Date when the participant completed enrollment.
    public let enrollmentDate: Date?
}

/// Participant's gender.
public struct ParticipantGender: RawRepresentable, Equatable, Decodable {
    public typealias RawValue = String
    /// The raw string encoding the gender value in RKStudio.
    public let rawValue: String
    
    /// Female gender as represented in RKStudio.
    public static let female = ParticipantGender(rawValue: "F")
    /// Male gender as represented in RKStudio.
    public static let male = ParticipantGender(rawValue: "M")
    /// Other gender as represented in RKStudio.
    public static let other = ParticipantGender(rawValue: "O")
    
    /// Initializes a `ParticipantGender` with an arbitrary value. Consider using static members such as `ParticipantGender.female` instead for known values.
    /// - Parameter rawValue: The raw string value as represented in RKStudio.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Demographic fields populated for a participant.
public struct ParticipantDemographics: Decodable {
    /// Participant's email address.
    public let email: String?
    /// Participant's mobile phone number
    public let mobilePhone: String?
    /// Participant's first name.
    public let firstName: String?
    /// Participant's middle name.
    public let middleName: String?
    /// Participant's last name.
    public let lastName: String?
    /// A component of a participant's street address.
    public let street1: String?
    /// A component of a participant's street address.
    public let street2: String?
    /// A component of a participant's street address.
    public let city: String?
    /// A component of a participant's street address.
    public let state: String?
    /// A component of a participant's street address.
    public let postalCode: String?
    /// Participant's date of birth, with format `yyyy-MM-dd`.
    public let dateOfBirth: String?
    /// Participant's preferred language, as an ISO language code.
    public let preferredLanguage: String?
    /// Participant's gender.
    public let gender: ParticipantGender?
    /// Participant's local time zone represented as a UTC offset, e.g., "-04:00:00".
    public let utcOffset: String?
    /// Participant's local time zone identifier, e.g. `"America/New_York"`.
    public let timeZone: String?
    
    /// The raw decodable value: "true" or "false".
    private let unsubscribedFromEmails: String?
    
    /// Indicates that the participant has unsubscribed from MyDataHelps email notifications.
    public var isUnsubscribedFromEmails: Bool {
        unsubscribedFromEmails == "true"
    }
}
