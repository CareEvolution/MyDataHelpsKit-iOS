//
//  SurveyTaskQueryResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/11/21.
//

import Foundation

struct SurveyTaskQueryResource: ParticipantResource {
    typealias ResponseType = SurveyTaskResultPage
    
    let query: SurveyTaskQuery
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        var queryItems: [URLQueryItem] = []
        if let statuses = query.statuses?.map({ $0.rawValue }).commaDelimitedQueryValue {
            queryItems.append(.init(name: "status", value: statuses))
        }
        if let surveyID = query.surveyID {
            queryItems.append(.init(name: "surveyID", value: surveyID.value))
        }
        if let surveyNames = query.surveyNames?.commaDelimitedQueryValue {
            queryItems.append(.init(name: "surveyName", value: surveyNames))
        }
        if let sortOrder = query.sortOrder {
            queryItems.append(.init(name: "sortOrder", value: sortOrder.rawValue))
        }
        
        queryItems.append(.init(name: "limit", value: String(query.limit)))
        if let pageID = query.pageID {
            queryItems.append(.init(name: "pageID", value: pageID.value))
        }
        
        let url = try session.client.endpoint(path: "api/v1/delegated/surveytasks", queryItems: queryItems)
        return session.authenticatedRequest(.GET, url: url)
    }
}
