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
    private let query: NotificationHistoryQuery
    
    init(session: ParticipantSessionType, query: NotificationHistoryQuery) {
        self.session = session
        self.query = query
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
            return query.page(after: page)
        } else {
            return query
        }
    }
}

extension NotificationHistoryPage: PageModelType {
    func pageItems(session: ParticipantSessionType) -> [NotificationHistoryView.Model] {
        notifications.map { .init(item: $0) }
    }
}
