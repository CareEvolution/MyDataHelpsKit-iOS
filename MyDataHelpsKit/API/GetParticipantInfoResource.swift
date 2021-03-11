//
//  GetParticipantInfoResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

struct GetParticipantInfoResource: ParticipantResource {
    typealias ResponseType = ParticipantInfo
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        session.authenticatedRequest(.GET, url: session.client.endpoint(path: "api/v1/delegated/participant"))
    }
}
