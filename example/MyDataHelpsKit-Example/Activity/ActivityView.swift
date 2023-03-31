//
//  ActivityView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

struct ActivityView: View {
    static let tabTitle = "Activity"
    
    @StateObject var model: ActivityViewModel
    
    var body: some View {
        NavigationStack(path: $model.path) {
            List {
                Section("Recent Notifications") {
                    AsyncCardView(result: model.recentNotifications, failureTitle: "Failed to load notifications") { page in
                        if page.notifications.isEmpty {
                            Text("No recent notifications.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(page.notifications) { item in
                                NotificationHistoryView(model: .init(item: item))
                            }
                        }
                    }
                    NavigationLink("All Notifications", value: ActivityNavigationPath.allNotifications)
                }
                
                Section {
                    AsyncCardView(result: model.recentSurveyAnswers, failureTitle: "Failed to load survey answers") { page in
                        if page.surveyAnswers.isEmpty {
                            Text("No recent survey answers.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(page.surveyAnswers) { item in
                                SurveyAnswerView(model: .init(session: model.session, answer: item))
                            }
                        }
                    }
                    NavigationLink("Survey History", value: ActivityNavigationPath.allSurveyAnswers)
                } header: {
                    Text("Recent Survey Answers")
                } footer: {
                    if case let .success(page) = model.recentSurveyAnswers,
                       !page.surveyAnswers.isEmpty {
                        Text("Thanks for participating!")
                    } else {
                        EmptyView()
                    }
                }
            }
            .listStyle(.sidebar) // Enables collapsible sections
            .refreshable {
                await model.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: ParticipantSession.participantDidUpdateNotification)) { _ in
                Task {
                    await model.refresh()
                }
            }
            .onAppear { model.loadData() }
            .navigationTitle(Self.tabTitle)
            .navigationDestination(for: ActivityNavigationPath.self) { destination in
                switch destination {
                case .allNotifications:
                    /// EXERCISE: this presents an infinite-scrolling list of all of the notifications sent to the participant (or attempted). Try customizing the NotificationHistoryQuery's optional parameters, or modify NotificationHistoryView.swift to explore and display other data available for each notification item.
                    PagedListView(model: NotificationHistoryQuery().pagedListViewModel(model.session)) { item in
                        NotificationHistoryView(model: item)
                    }
                    .navigationTitle("All Notifications")
                    
                case .allSurveyAnswers:
                    /// EXERCISE: this presents an infinite-scrolling list of all of the survey answers submitted by the participant. Try customizing the SurveyAnswersQuery's optional parameters, or modify SurveyAnswerView.swift to explore and display other data available for each survey answer.
                    PagedListView(model: SurveyAnswersQuery().pagedListViewModel(model.session)) { item in
                        SurveyAnswerView(model: item)
                    }
                    .navigationTitle("All Survey Answers")
                }
            }
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(model: .init(session: ParticipantSessionPreview()))
        ActivityView(model: .init(session: ParticipantSessionPreview(empty: true)))
    }
}
