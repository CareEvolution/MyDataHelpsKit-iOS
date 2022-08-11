//
//  ProjectResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/11/22.
//

import Foundation

struct GetProjectInfoResource: ParticipantResource {
    typealias ResponseType = ProjectInfo
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        session.authenticatedRequest(.GET, url: session.client.endpoint(path: "api/v1/delegated/project"))
    }
}
