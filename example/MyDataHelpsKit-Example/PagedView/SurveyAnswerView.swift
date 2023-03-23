//
//  SurveyAnswerView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct SurveyAnswerView: View {
    static func pageView(session: ParticipantSessionType, surveyID: Survey.ID?) -> PagedListView<SurveyAnswersSource, SurveyAnswerView> {
        /// EXERCISE: Add parameters to this `SurveyAnswersQuery` to further customize filtering.
        let query = SurveyAnswersQuery(surveyID: surveyID)
        let source = SurveyAnswersSource(session: session, query: query)
        return PagedListView(model: .init(source: source) { item in
            SurveyAnswerView(model: item)
        })
    }
    
    @MainActor class Model: Identifiable, ObservableObject {
        enum DeletionState {
            case notDeleted
            case deleted
            case failure(MyDataHelpsError)
        }
        
        let session: ParticipantSessionType
        let id: SurveyAnswer.ID
        let surveyResultID: SurveyResult.ID
        let value: String
        let date: Date?
        let surveyDisplayName: String
        @Published var deletionState = DeletionState.notDeleted
        
        init(session: ParticipantSessionType, id: SurveyAnswer.ID, surveyResultID: SurveyResult.ID, value: String, date: Date?, surveyDisplayName: String, deletionState: DeletionState = .notDeleted) {
            self.session = session
            self.id = id
            self.surveyResultID = surveyResultID
            self.value = value
            self.date = date
            self.surveyDisplayName = surveyDisplayName
            self.deletionState = deletionState
        }
        
        init(session: ParticipantSessionType, answer: SurveyAnswer) {
            self.session = session
            self.id = answer.id
            self.surveyResultID = answer.surveyResultID
            self.value = answer.answers.joined(separator: ", ")
            self.date = answer.date
            self.surveyDisplayName = answer.surveyDisplayName
            self.deletionState = .notDeleted
        }
        
        func delete() {
            Task {
                guard case .notDeleted = deletionState else { return }
                do {
                    try await session.deleteSurveyResult(surveyResultID)
                    deletionState = .deleted
                } catch {
                    deletionState = .failure(MyDataHelpsError(error))
                }
            }
        }
    }
    
    @StateObject var model: Model
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.value)
                /// EXERCISE: Add or modify `Text` views here to see the values of other `SurveyAnswer` properties.
                Text(model.surveyDisplayName)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
            }
            Spacer()
            switch model.deletionState {
            case .notDeleted:
                Button(action: { model.delete() }, label: {
                    Image(systemName: "trash")
                })
            case .deleted:
                Image(systemName: "multiply")
            case .failure:
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(Color(.systemRed))
            }
        }.foregroundColor(deletionStateColor)
    }
    
    var deletionStateColor: Color? {
        if case .deleted = model.deletionState {
            return Color(.systemGray)
        }
        return nil
    }
}

struct SurveyAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SurveyAnswerView(model: .init(session: ParticipantSessionPreview(), id: .init("sa1"), surveyResultID: .init("sr1"), value: "Answer Value", date: Date(), surveyDisplayName: "Survey Name", deletionState: .notDeleted))
                .padding()
            SurveyAnswerView(model: .init(session: ParticipantSessionPreview(), id: .init("sa1"), surveyResultID: .init("sr1"), value: "Answer Value", date: Date(), surveyDisplayName: "Survey Name", deletionState: .deleted))
                .padding()
            SurveyAnswerView(model: .init(session: ParticipantSessionPreview(), id: .init("sa1"), surveyResultID: .init("sr1"), value: "Answer Value", date: Date(), surveyDisplayName: "Survey Name", deletionState: .failure(.unknown(nil))))
                .padding()
        }
    }
}
