//
//  SurveyAnswersQueryResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/19/21.
//

import Foundation

struct SurveyAnswersQueryResource: ParticipantResource {
    typealias ResponseType = SurveyAnswersPage
    
    let query: SurveyAnswersQuery
    
    func urlRequest(session: ParticipantSession) throws -> URLRequest {
        var queryItems: [URLQueryItem] = []
        if let surveyResultID = query.surveyResultID {
            queryItems.append(.init(name: "surveyResultID", value: surveyResultID.value))
        }
        if let surveyID = query.surveyID {
            queryItems.append(.init(name: "surveyID", value: surveyID.value))
        }
        if let surveyNames = query.surveyNames?.commaDelimitedQueryValue {
            queryItems.append(.init(name: "surveyName", value: surveyNames))
        }
        if let after = query.after?.queryStringEncoded {
            queryItems.append(.init(name: "after", value: after))
        }
        if let before = query.before?.queryStringEncoded {
            queryItems.append(.init(name: "before", value: before))
        }
        if let insertedAfter = query.insertedAfter?.queryStringEncoded {
            queryItems.append(.init(name: "insertedAfter", value: insertedAfter))
        }
        if let insertedBefore = query.insertedBefore?.queryStringEncoded {
            queryItems.append(.init(name: "insertedBefore", value: insertedBefore))
        }
        if let stepIdentifiers = query.stepIdentifiers?.commaDelimitedQueryValue {
            queryItems.append(.init(name: "stepIdentifier", value: stepIdentifiers))
        }
        if let resultIdentifiers = query.resultIdentifiers?.commaDelimitedQueryValue {
            queryItems.append(.init(name: "resultIdentifier", value: resultIdentifiers))
        }
        if let answers = query.answers?.commaDelimitedQueryValue {
            queryItems.append(.init(name: "answer", value: answers))
        }
        
        queryItems.append(.init(name: "limit", value: String(query.limit)))
        if let pageID = query.pageID {
            queryItems.append(.init(name: "pageID", value: pageID.value))
        }
        
        let url = try session.client.endpoint(path: "api/v1/delegated/surveyanswers", queryItems: queryItems)
        return session.authenticatedRequest(.GET, url: url)
    }
}
