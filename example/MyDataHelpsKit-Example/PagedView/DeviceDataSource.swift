//
//  DeviceDataSource.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

class DeviceDataSource: PagedModelSource {
    struct ItemModel: Identifiable, Codable {
        let namespace: DeviceDataNamespace
        let id: DeviceDataPoint.ID
        let identifier: String?
        let type: String
        let value: String
        let units: String?
        let source: DeviceDataPointSource?
        let startDate: Date?
        let observationDate: Date?
    }
    
    let session: ParticipantSessionType
    private let query: DeviceDataQuery
    
    init(session: ParticipantSessionType, query: DeviceDataQuery) {
        self.session = session
        self.query = query
    }
    
    func loadPage(after page: DeviceDataResultPage?) async throws -> DeviceDataResultPage? {
        if let query = query(after: page) {
            return try await session.queryDeviceData(query)
        } else {
            return nil
        }
    }
    
    private func query(after page: DeviceDataResultPage?) -> DeviceDataQuery? {
        if let page = page {
            return query.page(after: page)
        } else {
            return query
        }
    }
}

extension DeviceDataResultPage: PageModelType {
    func pageItems(session: ParticipantSessionType) -> [DeviceDataSource.ItemModel] {
        deviceDataPoints.map { .init(dataPoint: $0) }
    }
}

extension DeviceDataSource.ItemModel {
    init(dataPoint: DeviceDataPoint) {
        self.namespace = dataPoint.namespace
        self.id = dataPoint.id
        self.identifier = dataPoint.identifier
        self.type = dataPoint.type
        self.value = dataPoint.value
        self.units = dataPoint.units
        self.source = dataPoint.source
        self.startDate = dataPoint.startDate
        self.observationDate = dataPoint.observationDate
    }
}
