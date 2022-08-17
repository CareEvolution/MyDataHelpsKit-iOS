//
//  ConnectExternalAccountResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/30/21.
//

import Foundation

struct ConnectExternalAccountResource: ParticipantResource {
    typealias ResponseType = URL
    
    let providerID: ExternalAccountProvider.ID
    let finalRedirectURL: URL

    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        return session.authenticatedRequest(.POST, url: try session.client.endpoint(path: "api/v1/delegated/externalaccountproviders/\(providerID)/connect", queryItems: [.init(name: "finalRedirectPath", value: finalRedirectURL.absoluteString)]))
    }
}
