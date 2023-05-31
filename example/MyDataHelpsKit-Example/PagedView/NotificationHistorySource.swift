//
//  NotificationHistorySource.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

class NotificationHistorySource: PagedModelSource {
    let session: ParticipantSessionType
    private let criteria: NotificationHistoryQuery
    
    init(session: ParticipantSessionType, criteria: NotificationHistoryQuery) {
        self.session = session
        self.criteria = criteria
    }
    
    func loadPage(after page: NotificationHistoryPage?) async throws -> NotificationHistoryPage? {
        if let query = query(after: page) {
            return try await session.queryNotifications(query)
        } else {
            return nil
        }
    }
    
    private func query(after page: NotificationHistoryPage?) -> NotificationHistoryQuery? {
        if let page = page {
            return criteria.page(after: page)
        } else {
            return criteria
        }
    }
}

extension NotificationHistoryPage: PageModelType {
    func pageItems(session: ParticipantSessionType) -> [NotificationHistoryView.Model] {
        notifications.map { .init(item: $0) }
    }
}
