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
    private let criteria: SurveyTaskQuery
    
    init(session: ParticipantSessionType, criteria: SurveyTaskQuery) {
        self.session = session
        self.criteria = criteria
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
            return criteria.page(after: page)
        } else {
            return criteria
        }
    }
}

extension SurveyTaskResultPage: PageModelType {
    func pageItems(session: ParticipantSessionType) -> [SurveyTaskView.Model] {
        surveyTasks.map { .init(session: session, task: $0) }
    }
}
