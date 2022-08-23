//
//  DeleteSurveyResultResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/19/21.
//

import Foundation

struct DeleteSurveyResultResource: ParticipantResource {
    typealias ResponseType = Void
    
    let surveyResultID: SurveyResult.ID
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        // Ensure it's a valid UUID so we can produce a safe URL path
        guard let id = UUID(uuidString: surveyResultID.value) else {
            throw EncodingError.invalidValue(surveyResultID, .init(codingPath: [], debugDescription: "surveyResultID should be a UUID"))
        }
        return session.authenticatedRequest(.DELETE, url: session.client.endpoint(path: "api/v1/delegated/surveyresults/\(id.uuidString)"))
    }
}
