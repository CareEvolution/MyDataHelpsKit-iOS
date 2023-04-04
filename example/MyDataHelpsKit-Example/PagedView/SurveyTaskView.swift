//
//  SurveyTaskView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

extension SurveyTaskQuery {
    @MainActor func pagedListViewModel(_ session: ParticipantSessionType) -> PagedViewModel<SurveyTaskSource> {
        PagedViewModel(source: SurveyTaskSource(session: session, query: self))
    }
}

struct SurveyTaskView: View {
    struct Model: Identifiable {
        let session: ParticipantSessionType
        let id: SurveyTask.ID
        let surveyID: Survey.ID
        let surveyDisplayName: String
        let dueDate: Date?
        let hasSavedProgress: Bool
        let status: SurveyTaskStatus
        let surveyName: String
    }
    
    let model: Model
    var presentedSurvey: Binding<SurveyPresentation?>
    
    var body: some View {
        Group {
            if model.status == .complete {
                NavigationLink(value: TasksNavigationPath.surveyAnswers(model.surveyID, model.surveyDisplayName)) {
                    content
                }
            } else {
                content
                    .onTapGesture(perform: launchSurvey)
            }
        }
    }
    
    private var content: some View {
        HStack {
            switch (model.status, model.hasSavedProgress) {
            case (.incomplete, false):
                Image(systemName: "square")
            case (.incomplete, true):
                Image(systemName: "ellipsis.rectangle")
            case (.complete, _):
                Image(systemName: "checkmark.square")
            case (.closed, _):
                Image(systemName: "checkmark.square.fill")
            default:
                Image(systemName: "questionmark.square.dashed")
            }
            VStack(alignment: .leading) {
                /// EXERCISE: Add or modify views here to see the values of other `SurveyTask` properties.
                Text(model.surveyDisplayName)
                if let dueDate = model.dueDate {
                    Text(dueDate.formatted())
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                }
            }
            Spacer()
        }
    }

    private func launchSurvey() {
        // Ignore if using a stubbed session from a preview provider.
        guard model.status == .incomplete,
              let session = model.session as? ParticipantSession else {
            return
        }
        presentedSurvey.wrappedValue = session.surveyPresentation(surveyName: model.surveyName)
    }
}

extension SurveyTaskView.Model {
    init(session: ParticipantSessionType, task: SurveyTask) {
        self.session = session
        self.id = task.id
        self.surveyID = task.surveyID
        self.surveyDisplayName = task.surveyDisplayName
        self.dueDate = task.dueDate
        self.hasSavedProgress = task.hasSavedProgress
        self.status = task.status
        self.surveyName = task.surveyName
    }
}

struct SurveyTaskView_Previews: PreviewProvider {
    @State private static var presentedSurvey: SurveyPresentation? = nil
    
    static var previews: some View {
        NavigationStack {
            List {
                SurveyTaskView(model: .init(session: ParticipantSessionPreview(), id: .init("t1"), surveyID: .init("s1"), surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .incomplete, surveyName: "name"), presentedSurvey: $presentedSurvey)
                SurveyTaskView(model: .init(session: ParticipantSessionPreview(), id: .init("t1"), surveyID: .init("s1"), surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .complete, surveyName: "name"), presentedSurvey: $presentedSurvey)
            }
            .sheet(item: $presentedSurvey) { presented in
                Text("Present survey: \(presented.surveyName)")
            }
        }
    }
}
