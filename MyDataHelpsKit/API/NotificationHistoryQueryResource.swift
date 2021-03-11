//
//  NotificationHistoryQueryResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/22/21.
//

import Foundation

struct NotificationHistoryQueryResource: ParticipantResource {
    typealias ResponseType = NotificationHistoryPage
    
    let query: NotificationHistoryQuery
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        var queryItems: [URLQueryItem] = []
        
        if let identifier = query.identifier {
            queryItems.append(.init(name: "identifier", value: identifier))
        }
        if let sentAfter = query.sentAfter?.queryStringEncoded {
            queryItems.append(.init(name: "sentAfter", value: sentAfter))
        }
        if let sentBefore = query.sentBefore?.queryStringEncoded {
            queryItems.append(.init(name: "sentBefore", value: sentBefore))
        }
        if let type = query.type {
            queryItems.append(.init(name: "type", value: type.rawValue))
        }
        if let statusCode = query.statusCode {
            queryItems.append(.init(name: "statusCode", value: statusCode.rawValue))
        }
        
        queryItems.append(.init(name: "limit", value: "\(query.limit)"))
        if let pageID = query.pageID {
            queryItems.append(.init(name: "pageID", value: pageID))
        }
        
        return session.authenticatedRequest(.GET, url: try session.client.endpoint(path: "api/v1/delegated/notifications", queryItems: queryItems))
    }
}
