//
//  SurveyTaskView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct SurveyTaskView: View {
    @MainActor static func pageView(session: ParticipantSessionType, statuses: Set<SurveyTaskStatus>? = nil) -> PagedListView<SurveyTaskSource, SurveyTaskView> {
        /// EXERCISE: Add parameters to this `SurveyTaskQuery` to customize filtering.
        let query = SurveyTaskQuery(statuses: statuses)
        let source = SurveyTaskSource(session: session, query: query)
        return PagedListView(model: .init(source: source) { item in
            SurveyTaskView(model: item)
        })
    }
    
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
    @State private var showingAnswers = false
    @State private var presentedSurvey: SurveyPresentation? = nil
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .medium
        return df
    }()
    
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
        .sheet(item: $presentedSurvey) { presentation in
            PresentedSurveyView(presentation: $presentedSurvey, resultMessage: nil)
                .interactiveDismissDisabled()
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
                Text(model.surveyDisplayName)
                /// EXERCISE: Add or modify `Text` views here to see the values of other `SurveyTask` properties.
                if let dueDate = model.dueDate {
                    Text(Self.dateFormatter.string(from: dueDate))
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
        presentedSurvey = session.surveyPresentation(surveyName: model.surveyName)
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
    static var previews: some View {
        NavigationStack {
            List {
                SurveyTaskView(model: .init(session: ParticipantSessionPreview(), id: .init("t1"), surveyID: .init("s1"), surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .incomplete, surveyName: "name"))
                SurveyTaskView(model: .init(session: ParticipantSessionPreview(), id: .init("t1"), surveyID: .init("s1"), surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .complete, surveyName: "name"))
            }
        }
    }
}
