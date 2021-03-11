//
//  SurveyTaskView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct SurveyTaskView: View {
    static func pageView(session: ParticipantSessionType) -> PagedView<SurveyTaskSource, SurveyTaskView> {
        let query = SurveyTaskQuery()
        let source = SurveyTaskSource(session: session, query: query)
        return PagedView(model: .init(source: source) { item in
            SurveyTaskView(model: item)
        })
    }
    
    struct Model: Identifiable {
        let session: ParticipantSessionType
        let id: String
        let surveyID: String
        let surveyDisplayName: String
        let dueDate: Date?
        let hasSavedProgress: Bool
        let status: SurveyTaskStatus
    }
    
    let model: Model
    
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
                        .navigationTitle("Answers for \(model.surveyDisplayName)")
                        .navigationBarTitleDisplayMode(.inline)
                )
            }
            Spacer()
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
    }
}

struct SurveyTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                SurveyTaskView(model: .init(session: ParticipantSessionPreview(), id: "1", surveyID: "1", surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .incomplete))
                    .padding()
                SurveyTaskView(model: .init(session: ParticipantSessionPreview(), id: "1", surveyID: "1", surveyDisplayName: "Preview Survey", dueDate: Date(), hasSavedProgress: true, status: .complete))
                    .padding()
            }
        }
    }
}
