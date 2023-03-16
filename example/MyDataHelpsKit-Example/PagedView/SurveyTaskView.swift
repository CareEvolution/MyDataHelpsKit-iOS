//
//  SurveyTaskView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct SurveyTaskView: View {
    @MainActor static func pageView(session: ParticipantSessionType) -> PagedView<SurveyTaskSource, SurveyTaskView> {
        /// EXERCISE: Add parameters to this `SurveyTaskQuery` to customize filtering.
        let query = SurveyTaskQuery()
        let source = SurveyTaskSource(session: session, query: query)
        return PagedView(model: .init(source: source) { item in
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
            
            if model.status == .complete {
                NavigationLink(
                    "",
                    destination: SurveyAnswerView.pageView(session: model.session, surveyID: model.surveyID)
                        .navigationTitle("Answers for \(model.surveyDisplayName)"),
                    isActive: $showingAnswers
                )
            }
            Spacer()
        }
        .onTapGesture(perform: self.selected)
        .sheet(item: $presentedSurvey) { presentation in
            PresentedSurveyView(presentation: $presentedSurvey, resultMessage: nil)
                .interactiveDismissDisabled()
        }
    }

    /// For completed surveys, shows a SurveyAnswerView (via the NavigationLink bound to `$showingAnswers`) filtered to the selected survey task. For incomplete tasks, presents a `SurveyViewController` to allow completing the survey.
    private func selected() {
        switch model.status {
        case .complete:
            showingAnswers = true
        case .incomplete:
            // Ignore if using a stubbed session from a preview provider.
            if let session = model.session as? ParticipantSession {
                presentedSurvey = session.surveyPresentation(surveyName: model.surveyName)
            }
        default:
            break
        }
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
        NavigationView {
            VStack {
                SurveyTaskView(model: .init(session: ParticipantSessionPreview(), id: .init("t1"), surveyID: .init("s1"), surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .incomplete, surveyName: "name"))
                SurveyTaskView(model: .init(session: ParticipantSessionPreview(), id: .init("t1"), surveyID: .init("s1"), surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .complete, surveyName: "name"))
            }
        }
    }
}
