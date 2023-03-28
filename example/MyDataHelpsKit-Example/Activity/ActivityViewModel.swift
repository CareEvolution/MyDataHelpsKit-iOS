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
    @Published var recentNotifications: Result<NotificationHistoryPage, MyDataHelpsError>? = nil
    @Published var recentSurveyAnswers: Result<SurveyAnswersPage, MyDataHelpsError>? = nil
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func loadData() {
        Task {
            if case .some(.success) = recentNotifications { return }
            /// EXERCISE: An example of using the MyDataHelpsKit paged-result pattern to load and display a single batch of recent data, rather than an entire infinite-scrolling list. Try customizing the NotificationHistoryQuery here.
            recentNotifications = await Result(wrapping: try await session.queryNotifications(NotificationHistoryQuery(statusCode: .succeeded, limit: 3)))
        }
        
        Task {
            if case .some(.success) = recentSurveyAnswers { return }
            /// EXERCISE: An example of using the MyDataHelpsKit paged-result pattern to load and displaying a single batch of recent data, rather than an entire infinite-scrolling list. Try customizing the NotificationHistoryQuery here.
            recentSurveyAnswers = await Result(wrapping: try await session.querySurveyAnswers(SurveyAnswersQuery(limit: 5)))
        }
    }
}
