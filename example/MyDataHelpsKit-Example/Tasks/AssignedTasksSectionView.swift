//
//  AssignedTasksSectionView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 4/4/23.
//

import SwiftUI
import MyDataHelpsKit

struct AssignedTasksSectionView: View {
    @ObservedObject var tasksModel: PagedViewModel<SurveyTaskSource>
    var presentedSurvey: Binding<SurveyPresentation?>
    
    var body: some View {
        Section("Incomplete Tasks") {
            switch tasksModel.state {
            case .empty:
                PagedEmptyContentView(text: "No assigned tasks")
            case let .failure(error):
                PagedFailureContentView(error: error)
            case .normal:
                PagedContentItemsView(model: tasksModel, inlineProgressViewVisibility: .allFetches) { task in
                    SurveyTaskView(model: task, presentedSurvey: presentedSurvey)
                }
            }
        }
    }
}

struct AssignedTasksSectionView_Previews: PreviewProvider {
    @State private static var presentedSurvey: SurveyPresentation? = nil
    
    static var previews: some View {
        NavigationStack {
            List {
                AssignedTasksSectionView(tasksModel: SurveyTaskQuery().pagedListViewModel(ParticipantSessionPreview()), presentedSurvey: $presentedSurvey)
                AssignedTasksSectionView(tasksModel: SurveyTaskQuery().pagedListViewModel(ParticipantSessionPreview(empty: true)), presentedSurvey: $presentedSurvey)
            }
        }
    }
}
