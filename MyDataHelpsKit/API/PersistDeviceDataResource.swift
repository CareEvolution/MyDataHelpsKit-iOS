//
//  PersistDeviceDataResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

struct PersistDeviceDataResource: ParticipantResource {
    typealias ResponseType = Void
    
    let dataPoints: [DeviceDataPointPersistModel]
    
    init(dataPoints: [DeviceDataPointPersistModel]) {
        self.dataPoints = dataPoints
    }
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        var request = session.authenticatedRequest(.POST, url: session.client.endpoint(path: "api/v1/delegated/devicedata"))
        try request.setJSONBody(dataPoints)
        return request
    }
}
