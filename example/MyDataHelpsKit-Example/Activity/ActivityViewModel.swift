//
//  ActivityViewModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

enum ActivityNavigationPath: Codable, Hashable {
    case allNotifications
    case allSurveyAnswers
}

@MainActor class ActivityViewModel: ObservableObject {
    let session: ParticipantSessionType
    
    @Published var path = NavigationPath()
    @Published var recentNotifications: RemoteResult<NotificationHistoryPage> = .loading
    @Published var recentSurveyAnswers: RemoteResult<SurveyAnswersPage> = .loading
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func loadData() {
        Task {
            await loadRecentNotifications(force: false)
        }
        
        Task {
            await loadRecentSurveyAnswers(force: false)
        }
    }
    
    func refresh() async {
        await loadRecentNotifications(force: true)
        await loadRecentSurveyAnswers(force: true)
    }
    
    private func loadRecentNotifications(force: Bool) async {
        if case .success = recentNotifications {
            guard force else { return }
        }
        /// EXERCISE: An example of using the MyDataHelpsKit paged-result pattern to load and display a single batch of recent data, rather than an entire infinite-scrolling list. Try customizing the NotificationHistoryQuery here.
        recentNotifications = await RemoteResult(wrapping: try await session.queryNotifications(NotificationHistoryQuery(statusCode: .succeeded, limit: 3)))
    }
    
    private func loadRecentSurveyAnswers(force: Bool) async {
        if case .success = recentSurveyAnswers {
            guard force else { return }
        }
        /// EXERCISE: An example of using the MyDataHelpsKit paged-result pattern to load and displaying a single batch of recent data, rather than an entire infinite-scrolling list. Try customizing the NotificationHistoryQuery here.
        recentSurveyAnswers = await RemoteResult(wrapping: try await session.querySurveyAnswers(SurveyAnswersQuery(limit: 5)))
    }
}
