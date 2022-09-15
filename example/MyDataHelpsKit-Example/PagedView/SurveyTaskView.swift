//
//  SurveyTaskView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct SurveyTaskView: View {
    @MainActor static func pageView(session: ParticipantSessionType, participantInfo: ParticipantInfoViewModel, embeddableSurveySelection: Binding<EmbeddableSurveySelection?>) -> PagedView<SurveyTaskSource, SurveyTaskView> {
        /// EXERCISE: Add parameters to this `SurveyTaskQuery` to customize filtering.
        let query = SurveyTaskQuery()
        let source = SurveyTaskSource(session: session, query: query)
        return PagedView(model: .init(source: source) { item in
            SurveyTaskView(model: item, participantLinkIdentifier: participantInfo.linkIdentifier, embeddableSurveySelection: embeddableSurveySelection)
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
        let linkIdentifier: SurveyTaskLink.ID?
    }
    
    let model: Model
    let participantLinkIdentifier: ParticipantLink.ID?
    @State var showingAnswers = false
    @State var embeddableSurveySelection: Binding<EmbeddableSurveySelection?>
    
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
    }
    
    private var embeddableSurveyContext: EmbeddableSurveySelection? {
        guard model.status == .incomplete,
              let participantLinkIdentifier = participantLinkIdentifier else {
            return nil
        }
        return .init(survey: model.embeddableSurveyID, participantLinkIdentifier: participantLinkIdentifier)
    }

    /// For completed surveys, shows a SurveyAnswerView (via the NavigationLink bound to `$showingAnswers`) filtered to the selected survey task. For incomplete tasks, presents an `EmbeddableSurveyViewController` (via a binding in RootView) if the task is configured to support it.
    private func selected() {
        if model.status == .complete {
            showingAnswers = true
        } else if let embeddableSurveyContext = embeddableSurveyContext {
            embeddableSurveySelection.wrappedValue = embeddableSurveyContext
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
        self.linkIdentifier = task.linkIdentifier
    }
    
    var embeddableSurveyID: EmbeddableSurveyID {
        if let linkIdentifier = linkIdentifier {
            return .taskLinkIdentifier(linkIdentifier)
        } else {
            return .surveyName(surveyName)
        }
    }
}

struct SurveyTaskView_Previews: PreviewProvider {
    struct ContainerView: View {
        let model: SurveyTaskView.Model
        let participantLinkIdentifier: ParticipantLink.ID?
        @State var embeddableSurvey: EmbeddableSurveySelection? = nil
        var body: some View {
            SurveyTaskView(model: model, participantLinkIdentifier: participantLinkIdentifier, embeddableSurveySelection: $embeddableSurvey)
                .padding()
        }
    }
    
    static var previews: some View {
        NavigationView {
            VStack {
                ContainerView(model: .init(session: ParticipantSessionPreview(), id: .init("t1"), surveyID: .init("s1"), surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .incomplete, surveyName: "name", linkIdentifier: nil), participantLinkIdentifier: nil)
                ContainerView(model: .init(session: ParticipantSessionPreview(), id: .init("t1"), surveyID: .init("s1"), surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .complete, surveyName: "name", linkIdentifier: nil), participantLinkIdentifier: nil)
            }
        }
    }
}
