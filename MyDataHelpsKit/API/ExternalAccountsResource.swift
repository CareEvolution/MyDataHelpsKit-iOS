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
