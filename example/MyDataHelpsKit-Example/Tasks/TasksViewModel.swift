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
}

@MainActor class TasksViewModel: ObservableObject {
    @Published var path = NavigationPath()
    @Published var participant: ParticipantModel
    @Published var tasksModel: PagedViewModel<SurveyTaskSource>
    
    init(participant: ParticipantModel) {
        self.participant = participant
        self.tasksModel = SurveyTaskQuery(statuses: .init([.incomplete]))
            .pagedListViewModel(participant.session)
    }
}
