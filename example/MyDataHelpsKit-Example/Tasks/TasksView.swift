//
//  TasksView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/16/23.
//

import SwiftUI
import MyDataHelpsKit

struct TasksView: View {
    static let tabTitle = "Tasks"
    
    @StateObject var model: TasksViewModel
    @State private var presentedSurvey: SurveyPresentation? = nil
    @State private var presentedSurveyResult: String? = nil
    @State private var presentedSurveyResultOpacity = 0.0
    
    var body: some View {
        NavigationStack(path: $model.path) {
            ZStack(alignment: .bottom) {
                List {
                    Section {
                        ForEach(model.persistentSurveys) { survey in
                            Button(survey.surveyDisplayName) {
                                launchSurvey(surveyName: survey.surveyName)
                            }
                            .buttonStyle(.plain)
                        }
                        if model.persistentSurveys.isEmpty {
                            Text("EXERCISE: populate var persistentSurveys")
                        }
                        NavigationLink("Launch Another Survey", value: TasksNavigationPath.surveyLauncher)
                    } footer: {
                        Text("These surveys are presented by name, with no assigned task necessary.")
                    }
                    
                    Section("Incomplete Tasks") {
                        switch model.tasksModel.state {
                        case .empty:
                            PagedEmptyContentView(text: "No assigned tasks")
                        case let .failure(error):
                            PagedFailureContentView(error: error)
                        case .normal:
                            PagedContentItemsView(model: model.tasksModel, inlineProgressViewVisibility: .allFetches) { task in
                                SurveyTaskView(model: task, presentedSurvey: $presentedSurvey)
                            }
                        }
                    }
                    
                    Section("Completed Tasks") {
                        NavigationLink("View Completed Tasks", value: TasksNavigationPath.completedTasks)
                    }
                }
                .refreshable {
                    await model.refresh()
                }
                .onReceive(NotificationCenter.default.publisher(for: ParticipantSession.participantDidUpdateNotification)) { _ in
                    Task {
                        await model.refresh()
                    }
                }
                
                if let presentedSurveyResult {
                    GroupBox {
                        Text(presentedSurveyResult)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .font(.headline)
                            .padding(.horizontal)
                    }
                    .opacity(presentedSurveyResultOpacity)
                    .backgroundStyle(.white)
                    .cornerRadius(.infinity)
                    .shadow(color: .secondary.opacity(0.5), radius: 4)
                    .padding()
                    .transition(.opacity)
                    .onAppear(perform: hideSurveyPresentationResult)
                }
            }
            .navigationTitle(Self.tabTitle)
            .sheet(item: $presentedSurvey) { presented in
                PresentedSurveyView(presentation: $presentedSurvey, resultMessage: $presentedSurveyResult)
            }
            .navigationDestination(for: TasksNavigationPath.self) { destination in
                switch destination {
                case .surveyLauncher:
                    SurveyLauncherView(session: model.session)
                        .navigationTitle("Launch a Survey")
                
                case let .surveyAnswers(surveyID, surveyDisplayName):
                    PagedListView(model: SurveyAnswersQuery(surveyID: surveyID).pagedListViewModel(model.session)) { item in
                        SurveyAnswerView(model: item, showSurveyDisplayName: false)
                    }
                    .navigationTitle("Answers for \(surveyDisplayName)")
                    .navigationBarTitleDisplayMode(.inline)
                
                case .completedTasks:
                    PagedListView(model: SurveyTaskQuery(statuses: Set([.complete])).pagedListViewModel(model.session)) { task in
                        SurveyTaskView(model: task, presentedSurvey: $presentedSurvey)
                    }
                    .navigationTitle("Completed Tasks")
                }
            }
        }
    }
    
    private func launchSurvey(surveyName: String) {
        guard let session = model.session as? ParticipantSession else { return }
        presentedSurvey = session.surveyPresentation(surveyName: surveyName)
    }
    
    private func hideSurveyPresentationResult() {
        withAnimation {
            presentedSurveyResultOpacity = 1
        }
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation {
                presentedSurveyResultOpacity = 0
            }
            try? await Task.sleep(for: .milliseconds(500))
            presentedSurveyResult = nil
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(model: TasksViewModel(session: ParticipantSessionPreview()))
        TasksView(model: TasksViewModel(session: ParticipantSessionPreview(empty: true)))
    }
}
