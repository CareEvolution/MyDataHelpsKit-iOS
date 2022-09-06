//
//  SurveyTaskSource.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

class SurveyTaskSource: PagedModelSource {
    let session: ParticipantSessionType
    private let query: SurveyTaskQuery
    
    init(session: ParticipantSessionType, query: SurveyTaskQuery) {
        self.session = session
        self.query = query
    }
    
    func loadPage(after page: SurveyTaskResultPage?) async throws -> SurveyTaskResultPage? {
        if let query = query(after: page) {
            return try await session.querySurveyTasks(query)
        } else {
            return nil
        }
    }
    
    private func query(after page: SurveyTaskResultPage?) -> SurveyTaskQuery? {
        if let page = page {
            return query.page(after: page)
        } else {
            return query
        }
    }
}

extension SurveyTaskResultPage: PageModelType {
    func pageItems(session: ParticipantSessionType) -> [SurveyTaskView.Model] {
        surveyTasks.map { .init(session: session, task: $0) }
    }
}
