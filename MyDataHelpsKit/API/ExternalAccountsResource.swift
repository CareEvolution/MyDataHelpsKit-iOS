//
//  ExternalAccountsResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/25/21.
//

import Foundation

struct ExternalAccountsResource: ParticipantResource {
    typealias ResponseType = [ExternalAccount]
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        session.authenticatedRequest(.GET, url: session.client.endpoint(path: "api/v1/delegated/externalaccounts"))
    }
}

struct RefreshExternalAccountResource: ParticipantResource {
    typealias ResponseType = Void
    
    let id: ExternalAccount.ID
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        session.authenticatedRequest(.POST, url: session.client.endpoint(path: "/api/v1/delegated/externalaccounts/refresh/\(id)"))
    }
}

struct DeleteExternalAccountResource: ParticipantResource {
    typealias ResponseType = Void
    
    let id: ExternalAccount.ID
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        let queryItems = [URLQueryItem(name: "deleteData", value: "true")]
        return session.authenticatedRequest(.DELETE, url: try session.client.endpoint(path: "/api/cfhrprovideraccounts/account/\(id)", queryItems: queryItems))
    }
}
