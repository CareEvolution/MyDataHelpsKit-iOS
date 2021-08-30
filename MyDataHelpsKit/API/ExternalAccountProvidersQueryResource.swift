//
//  ExternalAccountProvidersQueryResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/24/21.
//

import Foundation

struct ExternalAccountProvidersQueryResource: ParticipantResource {
    typealias ResponseType = [ExternalAccountProvider]
    
    let query: ExternalAccountProvidersQuery
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        var queryItems: [URLQueryItem] = []
        
        if let search = query.search {
            queryItems.append(.init(name: "search", value: search))
        }
        if let category = query.category {
            queryItems.append(.init(name: "category", value: category.rawValue))
        }
        
        return session.authenticatedRequest(.GET, url: try session.client.endpoint(path: "api/v1/delegated/externalaccountproviders", queryItems: queryItems))
    }
}
