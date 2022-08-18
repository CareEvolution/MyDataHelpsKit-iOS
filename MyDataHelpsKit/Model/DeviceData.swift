//
//  DeviceData.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

/// Specifies filtering and page-navigation criteria for device data point queries.
///
/// All query properties are optional. Set non-nil/non-default values only for the properties you want to use for filtering.
///
/// You can filter device data by two different type of dates: `modifiedBefore/After` and `observedBefore/After`. Due to variations and limitations in device data synchronization, it is possible for older data points to turn up in the system unpredictably. Using the "observed" query parameters will search based on the date the data was observed or recorded by the device, while the "modified" parameters will search based on the date it arrived in the system. Use the `modifiedAfter` property to search for data that has arrived since a prior query.
public struct DeviceDataQuery: PagedQuery {
    /// The default and maximum number of results per page.
    public static let defaultLimit = 100
    
    /// Specifies the source framework for the device data.
    public let namespace: DeviceDataNamespace
    /// Filter by one or more types/categories within the given namespace, e.g. "HeartRate"
    public let types: Set<String>?
    /// Search for device data points observed after this date.
    public let observedAfter: Date?
    /// Search for device data points observed before this date.
    public let observedBefore: Date?
    /// Search for device data points updated in the system after this date.
    public let modifiedAfter: Date?
    /// Search for device data points updated in the system before this date.
    public let modifiedBefore: Date?
    
    /// Maximum number of results per page. Default and maximum value is 100.
    public let limit: Int
    /// Identifies a specific page of data to fetch. Use `nil` to fetch the first page of results. To fetch the page following a given `DeviceDataResultPage` use its `nextPageID`; the other parameters should be the same as the original `DeviceDataQuery`.
    public let pageID: String?
    
    /// Initializes a new query for a page of device data with various filters.
    /// - Parameters:
    ///   - namespace: Specifies the source framework for the device data.
    ///   - types: Filter by one or more types/categories within the given namespace, e.g. "HeartRate".
    ///   - observedAfter: Search for device data points observed after this date.
    ///   - observedBefore: Search for device data points observed before this date.
    ///   - modifiedAfter: Search for device data points updated in the system after this date.
    ///   - modifiedBefore: Search for device data points updated in the system before this date.
    ///   - limit: Maximum number of results per page.
    ///   - pageID: Identifies a specific page of data to fetch.
    public init(namespace: DeviceDataNamespace, types: Set<String>? = nil, observedAfter: Date? = nil, observedBefore: Date? = nil, modifiedAfter: Date? = nil, modifiedBefore: Date? = nil, limit: Int = defaultLimit, pageID: String? = nil) {
        self.namespace = namespace
        self.types = types
        self.observedAfter = observedAfter
        self.observedBefore = observedBefore
        self.modifiedAfter = modifiedAfter
        self.modifiedBefore = modifiedBefore
        self.limit = Self.clampedLimit(limit, max: Self.defaultLimit)
        self.pageID = pageID
    }
    
    /// Initializes a new query for a page of results following the given page, with the same filters as the original query.
    /// - Parameter page: the previous page of results, which should have been produced with this query.
    /// - Returns: A query for results following `page`, if page has a `nextPageID`. If there are no additional pages of results available, returns `nil`. The query returned, if any, has the same filters as the original.
    public func page(after page: DeviceDataResultPage) -> DeviceDataQuery? {
        guard let nextPageID = page.nextPageID else { return nil }
        return DeviceDataQuery(namespace: namespace, types: types, observedAfter: observedAfter, observedBefore: observedBefore, modifiedAfter: modifiedAfter, modifiedBefore: modifiedBefore, limit: limit, pageID: nextPageID)
    }
}

/// A page of device data points.
public struct DeviceDataResultPage: PagedResult, Decodable {
    /// A list of DeviceDataPoints filtered by the query criteria.
    public let deviceDataPoints: [DeviceDataPoint]
    /// An ID to be used with subsequent `DeviceDataQuery` requests. Results from queries using this ID as the `pageID` parameter will show the next page of results. `nil` if there isn't a next page.
    public let nextPageID: String?
}
    
/// Device data is grouped into namespaces, which represent the source frameworks that generate the data. There is also a separate `project` namespace, where projects can persist their own data. The static members of DeviceDataNamespace identify all supported namespace values.
public struct DeviceDataNamespace: RawRepresentable, Equatable, Decodable {
    public typealias RawValue = String
    
    /// Project-specific device data.
    public static let project = DeviceDataNamespace(rawValue: "Project")
    
    /// Data imported from a linked Fitbit account.
    public static let fitbit = DeviceDataNamespace(rawValue: "Fitbit")
    
    /// Data imported from a linked Apple Health account.
    public static let appleHealth = DeviceDataNamespace(rawValue: "AppleHealth")
    
    /// Data imported from a linked Google Fit account.
    public static let googleFit = DeviceDataNamespace(rawValue: "GoogleFit")
    
    /// Air quality index data imported from AirNow.gov.
    public static let airNowApi = DeviceDataNamespace(rawValue: "AirNowApi")
    
    /// Weather forecast data imported from WeatherBit.io.
    public static let weatherBit = DeviceDataNamespace(rawValue: "WeatherBit")
    
    /// Data imported from Omron wellness products.
    public static let omron = DeviceDataNamespace(rawValue: "Omron")
    
    /// The raw value for the namespace as stored in MyDataHelps.
    public let rawValue: String
    
    /// Initializes a `DeviceDataNamespace` with an arbitrary value. Consider using static members such as `DeviceDataNamespace.project` instead for known values.
    /// - Parameter rawValue: The raw value for the namespace as stored in MyDataHelps.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// A single device data point stored in MyDataHelps.
public struct DeviceDataPoint: Decodable {
    /// Auto-generated, globally-unique identifier.
    public let id: String
    /// Identifies device data as from a specific source system.
    public let namespace: DeviceDataNamespace
    /// Auto-generated, globally-unique identifier for a group of device data points, which share some context.
    public let deviceDataContextID: String?
    /// Date when the data point was first added.
    public let insertedDate: Date
    /// Date when the data point was last updated in the system.
    public let modifiedDate: Date
    /// String used to name a device data point.
    public let identifier: String?
    /// The type of device data within its namespace, e.g. "HeartRate".
    public let type: String
    /// The value of the recorded device data point.
    public let value: String
    /// The units, if any, that the device data was recorded in.
    public let units: String?
    /// Properties of the device data point.
    public let properties: [String: String]
    /// Identifying information about the device which recorded the data point.
    public let source: DeviceDataPointSource?
    /// The date at which this device data point began being recorded (for data that is recorded over time).
    public let startDate: Date?
    /// The date at which this device data point was completely recorded.
    public let observationDate: Date?
}

/// Describes a device data point to create or update.
public struct DeviceDataPointPersistModel: Encodable {
    /// String used to name a device data point. Optional. Natural Key property.
    public let identifier: String?
    /// The general category this device data point belongs in, or what the device data represents. Natural Key property.
    public let type: String
    /// The value of the recorded data point.
    public let value: String
    /// The units, if any, that the data was recorded in.
    public let units: String?
    /// Properties of the device data point.
    public let properties: [String: String]
    /// Identifying information about the device which recorded the data point.
    public let source: DeviceDataPointSource?
    /// The date at which this device data point began being recorded (for data that is recorded over time). Natural Key property.
    public let startDate: Date?
    /// The date at which this device data point was completely recorded. Natural Key property.
    public let observationDate: Date?
    
    /// Initializes an object describing device data point to create or update.
    /// - Parameters:
    ///   - identifier: String used to name a device data point. Optional. Natural Key property.
    ///   - type: The general category this device data point belongs in, or what the device data represents. Natural Key property.
    ///   - value: The value of the recorded data point.
    ///   - units: The units, if any, that the data was recorded in.
    ///   - properties: Properties of the device data point.
    ///   - source: Identifying information about the device which recorded the data point.
    ///   - startDate: The date at which this device data point began being recorded (for data that is recorded over time). Natural Key property.
    ///   - observationDate: The date at which this device data point was completely recorded. Natural Key property.
    public init(identifier: String?, type: String, value: String, units: String?, properties: [String : String], source: DeviceDataPointSource?, startDate: Date?, observationDate: Date?) {
        self.identifier = identifier
        self.type = type
        self.value = value
        self.units = units
        self.properties = properties
        self.source = source
        self.startDate = startDate
        self.observationDate = observationDate
    }
}

/// Identifying information about the device which recorded a data point.
public struct DeviceDataPointSource: Codable {
    /// Identifying string for the data source.
    public let identifier: String
    /// Properties describing the device data source.
    public let properties: [String: String]
    
    /// Initializes a new DeviceDataPointSource.
    public init(identifier: String, properties: [String : String]) {
        self.identifier = identifier
        self.properties = properties
    }
}
