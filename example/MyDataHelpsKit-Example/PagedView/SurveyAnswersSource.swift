//
//  SurveyAnswersSource.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

class SurveyAnswersSource: PagedModelSource {
    let session: ParticipantSessionType
    private let query: SurveyAnswersQuery
    
    init(session: ParticipantSessionType, query: SurveyAnswersQuery) {
        self.session = session
        self.query = query
    }
    
    func loadPage(after page: SurveyAnswersPage?) async throws -> SurveyAnswersPage? {
        if let query = query(after: page) {
            return try await session.querySurveyAnswers(query)
        } else {
            return nil
        }
    }
    
    private func query(after page: SurveyAnswersPage?) -> SurveyAnswersQuery? {
        if let page = page {
            return query.page(after: page)
        } else {
            return query
        }
    }
}

extension SurveyAnswersPage: PageModelType {
    @MainActor func pageItems(session: ParticipantSessionType) -> [SurveyAnswerView.Model] {
        surveyAnswers.map { .init(session: session, answer: $0) }
    }
}
