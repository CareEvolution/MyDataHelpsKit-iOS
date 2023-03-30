//
//  Project.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/11/22.
//

import Foundation

/// Information about the project and its settings.
public struct ProjectInfo: Identifiable, Decodable {
    /// Unique project identifier.
    public typealias ID = ScopedIdentifier<ProjectInfo, String>
    
    /// Unique project identifier.
    public let id: ID
    /// Project's display name, localized based on participant's language settings.
    public let name: String
    /// Project's display description, localized based on participant's language settings.
    public var description: String?
    /// Code used by participants to enroll in this project, if code enrollment is allowed.
    public let code: String
    /// Project type, displayed to participants and used to filter search results.
    public let type: ProjectType
    /// Information about the organization for this project.
    public let organization: Organization
    /// Contact email for project support displayed to participants.
    public var supportEmail: String?
    /// Contact number for project support displayed to participants.
    public var supportPhone: String?
    /// A URL where participants can learn more about the project.
    public var learnMoreURL: URL? {
        learnMoreLink.flatMap { URL(string: $0) }
    }
    /// Site name or title to use as a label for the ``learnMoreURL``, localized based on participant's language settings.
    public let learnMoreTitle: String?
    
    /// The raw decodable value, which may be an empty string or invalid URL.
    private var learnMoreLink: String?
}

/// Describes the type of a MyDataHelps project.
public struct ProjectType: RawRepresentable, Equatable, Codable {
    /// The raw value for the project type as stored in MyDataHelps.
    public let rawValue: String
    
    /// A research study.
    public static let researchStudy = ProjectType(rawValue: "Research Study")
    /// A wellness program.
    public static let wellnessProgram = ProjectType(rawValue: "Wellness Program")
    /// A clinical program.
    public static let clinicalProgram = ProjectType(rawValue: "Clinical Program")
    
    /// Initializes a `ProjectType` with an arbitrary value. Consider using static members such as `ProjectType.researchStudy` instead for known values.
    /// - Parameter rawValue: The raw value for the project type as stored in MyDataHelps.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Information about an organization.
public struct Organization: Identifiable, Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case logoURL = "logoUrl"
        case color
    }
    
    /// Unique organization identifier.
    public typealias ID = ScopedIdentifier<Organization, String>
    
    /// Unique organization identifier.
    public let id: ID
    /// Organization name.
    public let name: String
    /// Organization description.
    public let description: String?
    /// Full URL to the organization's logo image.
    ///
    /// This URL returns image data, e.g. `image/png`, suitable for decoding directly into a `UIImage` object and presenting in image views. It is a public URL with no authentication required. Image dimensions may vary, so it is recommended to display these images with aspect-fit scaling.
    public let logoURL: URL
    /// The organization's brand color, expressed as a hexadecimal string. For example, `"#000000"`.
    public let color: String
}

public struct ProjectDataCollectionSettings: Decodable {
    /// Indicates whether Fitbit data collection is enabled for this project.
    public let fitbitEnabled: Bool
    /// Indicates whether Electronic Health Record data collection is enabled for this project.
    public let ehrEnabled: Bool
    /// Indicates whether Air Quality data collection is enabled for this project.
    public let airQualityEnabled: Bool
    /// Indicates whether Weather data collection is enabled for this project.
    public let weatherEnabled: Bool
    /// A collection of device data types that are supported by the current project configuration and can be queried using `ParticipantSession.queryDeviceData`. A participant may not have data available for all data types.
    ///
    /// This includes data types for all DeviceDataNamespaces, except for the `project` namespace: although project-scoped device data can also be fetched using `queryDeviceData`, SDK developers must manage their own configuration for which device data types exist within their project's namespace.
    public let queryableDeviceDataTypes: Set<QueryableDeviceDataType>
    /// Date when sensor data collection ended or will end for this participant.
    ///
    /// More Info: [Stopping Device Data Collection](https://support.mydatahelps.org/hc/en-us/articles/4404704688915-Defining-End-of-Project-for-Participants#h_01FMARCJ1S5T80A6X4M115E551).
    public let sensorDataCollectionEndDate: Date?
}

/// Information about a single device data type that is supported by the current project configuration and can be queried using the Device Data API.
public struct QueryableDeviceDataType: Decodable, Equatable, Hashable {
    /// The namespace to use when querying for device data.
    public let namespace: DeviceDataNamespace
    /// The type to use when querying for device data.
    public let type: String
}
