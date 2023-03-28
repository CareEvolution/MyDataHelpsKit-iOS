//
//  TasksView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/16/23.
//

import SwiftUI
import MyDataHelpsKit

struct TasksView: View {
    @StateObject var model: TasksViewModel
    @State private var presentedSurvey: SurveyPresentation? = nil
    
    var body: some View {
        NavigationStack(path: $model.path) {
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
                        PagedContentItemsView(model: model.tasksModel, inlineProgressView: true) { task in
                            SurveyTaskView(model: task, presentedSurvey: $presentedSurvey)
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
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
                }
            }
            .sheet(item: $presentedSurvey) { presented in
                PresentedSurveyView(presentation: $presentedSurvey, resultMessage: nil)
            }
        }
    }
    
    private func launchSurvey(surveyName: String) {
        guard let session = model.session as? ParticipantSession else { return }
        presentedSurvey = session.surveyPresentation(surveyName: surveyName)
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(model: TasksViewModel(session: ParticipantSessionPreview()))
        TasksView(model: TasksViewModel(session: ParticipantSessionPreview(empty: true)))
    }
}
