//
//  DeviceDataPointTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 3/16/23.
//

import XCTest
@testable import MyDataHelpsKit

final class DeviceDataPointTests: XCTestCase {
    func testDeviceDataResultPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(DeviceDataResultPage.self, from: deviceDataResultPageJSON)
        XCTAssertEqual(page.nextPageID, nextPageID1)
        XCTAssertEqual(page.deviceDataPoints.count, 3)
        
        guard page.deviceDataPoints.count == 3 else { return }
        
        var point = page.deviceDataPoints[0]
        XCTAssertEqual(point.id, dataPointID1)
        XCTAssertEqual(point.namespace, .project)
        XCTAssertNil(point.deviceDataContextID)
        XCTAssertEqual(point.insertedDate.formatted(.iso8601), "2021-04-01T14:57:26Z")
        XCTAssertEqual(point.modifiedDate.formatted(.iso8601), "2021-04-02T14:57:26Z")
        XCTAssertNil(point.identifier)
        XCTAssertEqual(point.type, "PersistType1")
        XCTAssertEqual(point.value, "VALUE_1")
        XCTAssertNil(point.units)
        XCTAssertTrue(point.properties.isEmpty)
        XCTAssertEqual(point.source?.identifier, "sourceID1")
        XCTAssertEqual(point.source?.properties.isEmpty, true)
        XCTAssertNil(point.startDate)
        XCTAssertEqual(point.observationDate?.formatted(.iso8601), "2021-04-01T14:57:03Z")
        
        point = page.deviceDataPoints[1]
        XCTAssertEqual(point.id, dataPointID2)
        XCTAssertEqual(point.namespace, .appleHealth)
        XCTAssertNil(point.deviceDataContextID)
        XCTAssertEqual(point.insertedDate.formatted(.iso8601), "2022-08-08T23:54:31Z")
        XCTAssertEqual(point.modifiedDate.formatted(.iso8601), "2022-08-08T23:54:31Z")
        XCTAssertEqual(point.identifier, "identifier2")
        XCTAssertEqual(point.type, "HeartRate")
        XCTAssertEqual(point.value, "62")
        XCTAssertEqual(point.units, "count/min")
        XCTAssertEqual(point.properties["Metadata_HKMetadataKeyHeartRateMotionContext"], "1")
        XCTAssertEqual(point.source?.identifier, "sourceID2")
        XCTAssertEqual(point.source?.properties["DeviceName"], "Apple Watch")
        XCTAssertEqual(point.startDate?.formatted(.iso8601), "2022-08-08T15:10:32Z")
        XCTAssertEqual(point.observationDate?.formatted(.iso8601), "2022-08-08T15:10:32Z")
        
        point = page.deviceDataPoints[2]
        XCTAssertEqual(point.id, dataPointID3)
        XCTAssertEqual(point.namespace, .project)
        XCTAssertEqual(point.deviceDataContextID, contextID1)
        XCTAssertEqual(point.insertedDate.formatted(.iso8601), "2021-03-25T22:43:45Z")
        XCTAssertEqual(point.modifiedDate.formatted(.iso8601), "2021-03-25T22:43:45Z")
        XCTAssertEqual(point.identifier, "identifier3")
        XCTAssertEqual(point.type, "TestType1")
        XCTAssertEqual(point.value, "")
        XCTAssertEqual(point.units, "")
        XCTAssertNil(point.source)
        XCTAssertEqual(point.startDate?.formatted(.iso8601), "2021-03-24T22:27:45Z")
        XCTAssertEqual(point.observationDate?.formatted(.iso8601), "2021-03-24T22:46:45Z")
    }
    
    func testEmptyDeviceDataResultPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(DeviceDataResultPage.self, from: emptyDeviceDataResultPageJSON)
        XCTAssertNil(page.nextPageID)
        XCTAssertTrue(page.deviceDataPoints.isEmpty)
    }
    
    private let nextPageID1 = DeviceDataResultPage.PageID(UUID().uuidString)
    private let dataPointID1 = DeviceDataPoint.ID(UUID().uuidString)
    private let dataPointID2 = DeviceDataPoint.ID(UUID().uuidString)
    private let dataPointID3 = DeviceDataPoint.ID(UUID().uuidString)
    private let contextID1 = DeviceDataContext.ID(UUID().uuidString)
    
    private var deviceDataResultPageJSON: Data { """
{
  "deviceDataPoints": [
    {
      "id": "\(dataPointID1)",
      "namespace": "Project",
      "deviceDataContextID": null,
      "insertedDate": "2021-04-01T14:57:26.243Z",
      "modifiedDate": "2021-04-02T14:57:26.243Z",
      "identifier": null,
      "type": "PersistType1",
      "value": "VALUE_1",
      "units": null,
      "properties": {},
      "source": {
        "identifier": "sourceID1",
        "properties": {}
      },
      "startDate": null,
      "observationDate": "2021-04-01T10:57:03.541-04:00"
    },
    {
      "id": "\(dataPointID2)",
      "namespace": "AppleHealth",
      "deviceDataContextID": null,
      "insertedDate": "2022-08-08T23:54:31.747Z",
      "modifiedDate": "2022-08-08T23:54:31.747Z",
      "identifier": "identifier2",
      "type": "HeartRate",
      "value": "62",
      "units": "count/min",
      "properties": {
        "Metadata_HKMetadataKeyHeartRateMotionContext": "1"
      },
      "source": {
        "identifier": "sourceID2",
        "properties": {
          "SourceIdentifier": "...",
          "SourceName": "...",
          "SourceOperatingSystemVersion": "8.6.0",
          "SourceProductType": "Watch6,6",
          "SourceVersion": "8.6",
          "DeviceHardwareVersion": "Watch6,6",
          "DeviceManufacturer": "Apple Inc.",
          "DeviceModel": "Watch",
          "DeviceName": "Apple Watch",
          "DeviceSoftwareVersion": "8.6"
        }
      },
      "startDate": "2022-08-08T11:10:32-04:00",
      "observationDate": "2022-08-08T11:10:32-04:00"
    },
    {
      "id": "\(dataPointID3)",
      "namespace": "Project",
      "deviceDataContextID": "\(contextID1)",
      "insertedDate": "2021-03-25T22:43:45.687Z",
      "modifiedDate": "2021-03-25T22:43:45.687Z",
      "identifier": "identifier3",
      "type": "TestType1",
      "value": "",
      "units": "",
      "properties": {},
      "startDate": "2021-03-24T18:27:45.58-04:00",
      "observationDate": "2021-03-24T18:46:45.58-04:00"
    }
  ],
  "nextPageID": "\(nextPageID1)"
}
""".data(using: .utf8)! }
    
    private var emptyDeviceDataResultPageJSON: Data { """
{
  "deviceDataPoints": [],
  "nextPageID": null
}
""".data(using: .utf8)! }
}
