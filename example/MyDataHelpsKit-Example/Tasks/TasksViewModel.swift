//
//  TasksViewModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/23/23.
//

import SwiftUI
import MyDataHelpsKit

enum TasksNavigationPath: Codable, Hashable {
    case surveyLauncher
    case surveyAnswers(Survey.ID, String)
    case completedTasks
}

struct PersistentSurvey: Identifiable {
    var id: String { surveyName }
    let surveyName: String
    let surveyDisplayName: String
}

@MainActor class TasksViewModel: ObservableObject {
    let session: ParticipantSessionType
    
    @Published var path = NavigationPath()
    @Published var tasksModel: PagedViewModel<SurveyTaskSource>
    let persistentSurveys: [PersistentSurvey]
    
    init(session: ParticipantSessionType) {
        self.session = session
        
        /// EXERCISE: Modify the SurveyTaskQuery to customize the tasks shown.
        self.tasksModel = SurveyTaskQuery(statuses: .init([.incomplete]))
            .pagedListViewModel(session)
        
        /// EXERCISE: Use persistentSurveys for surveys in your project that can be launched by name at any time without an assigned task. These surveys are presented to the participant using `SurveyViewController`, see that class's documentation for more information.
        self.persistentSurveys = [
            PersistentSurvey(surveyName: "EMA1", surveyDisplayName: "Daily Mood Survey"),
            PersistentSurvey(surveyName: "EMA2", surveyDisplayName: "Daily Medication Survey")
        ]
    }
    
    func refresh() async {
        await tasksModel.reset()
    }
}
