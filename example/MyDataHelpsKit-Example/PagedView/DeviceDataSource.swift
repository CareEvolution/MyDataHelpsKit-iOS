//
//  DeviceDataSource.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

class DeviceDataSource: PagedModelSource {
    struct ItemModel: Identifiable {
        let session: ParticipantSessionType
        let namespace: DeviceDataNamespace
        let id: String
        let identifier: String
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
    
    func loadPage(after page: DeviceDataResultPage?, completion: @escaping (Result<DeviceDataResultPage, MyDataHelpsError>) -> Void) {
        if let query = query(after: page) {
            session.queryDeviceData(query, completion: completion)
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
        deviceDataPoints.map { .init(dataPoint: $0, session: session) }
    }
}

extension DeviceDataSource.ItemModel {
    init(dataPoint: DeviceDataPoint, session: ParticipantSessionType) {
        self.session = session
        self.namespace = dataPoint.namespace
        self.id = dataPoint.id
        self.identifier = dataPoint.identifier ?? ""
        self.type = dataPoint.type
        self.value = dataPoint.value
        self.units = dataPoint.units
        self.source = dataPoint.source
        self.startDate = dataPoint.startDate
        self.observationDate = dataPoint.observationDate
    }
}
