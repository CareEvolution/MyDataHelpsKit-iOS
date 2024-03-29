//
//  DeviceDataQueryResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

struct DeviceDataQueryResource: ParticipantResource {
    typealias ResponseType = DeviceDataResultPage
    
    let query: DeviceDataQuery
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        var queryItems: [URLQueryItem] = []
        queryItems.append(.init(name: "namespace", value: query.namespace.rawValue))
        if let types = query.types?.commaDelimitedQueryValue {
            queryItems.append(.init(name: "type", value: types))
        }
        if let observedAfter = query.observedAfter?.queryStringEncoded {
            queryItems.append(.init(name: "observedAfter", value: observedAfter))
        }
        if let observedBefore = query.observedBefore?.queryStringEncoded {
            queryItems.append(.init(name: "observedBefore", value: observedBefore))
        }
        if let modifiedAfter = query.modifiedAfter?.queryStringEncoded {
            queryItems.append(.init(name: "modifiedAfter", value: modifiedAfter))
        }
        if let modifiedBefore = query.modifiedBefore?.queryStringEncoded {
            queryItems.append(.init(name: "modifiedBefore", value: modifiedBefore))
        }
        
        queryItems.append(.init(name: "limit", value: String(query.limit)))
        if let pageID = query.pageID {
            queryItems.append(.init(name: "pageID", value: pageID.value))
        }
        
        let url = try session.client.endpoint(path: "api/v1/delegated/devicedata", queryItems: queryItems)
        return session.authenticatedRequest(.GET, url: url)
    }
}
