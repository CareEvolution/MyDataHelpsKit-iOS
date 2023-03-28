//
//  TasksView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/16/23.
//

import SwiftUI
import MyDataHelpsKit

struct TasksView: View {
    private struct PersistentSurvey: Identifiable {
        var id: String { surveyName }
        let surveyName: String
        let surveyDisplayName: String
    }
    
    @StateObject var model: TasksViewModel
    @State private var presentedSurvey: SurveyPresentation? = nil
    
    /// EXERCISE: Use persistentSurveys for surveys in your project that can be launched by name at any time without an assigned task. These surveys are presented to the participant using `SurveyViewController`, see that class's documentation for more information.
    private let persistentSurveys: [PersistentSurvey] = [
        PersistentSurvey(surveyName: "EMA1", surveyDisplayName: "Daily Mood Survey"),
        PersistentSurvey(surveyName: "EMA2", surveyDisplayName: "Daily Medication Survey")
    ]
    
    var body: some View {
        NavigationStack(path: $model.path) {
            List {
                Section {
                    ForEach(persistentSurveys) { survey in
                        Button(survey.surveyDisplayName) {
                            launchSurvey(surveyName: survey.surveyName)
                        }
                        .buttonStyle(.plain)
                    }
                    if persistentSurveys.isEmpty {
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
                    SurveyLauncherView(participant: model.participant)
                        .navigationTitle("Launch a Survey")
                case let .surveyAnswers(surveyID, surveyDisplayName):
                    PagedListView(model: SurveyAnswersQuery(surveyID: surveyID).pagedListViewModel(model.participant.session)) { item in
                        SurveyAnswerView(model: item)
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
        guard let session = model.participant.session as? ParticipantSession else { return }
        presentedSurvey = session.surveyPresentation(surveyName: surveyName)
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(model: TasksViewModel(participant: ParticipantModel(session: ParticipantSessionPreview())))
        TasksView(model: .init(participant: .init(session: ParticipantSessionPreview(empty: true))))
    }
}
