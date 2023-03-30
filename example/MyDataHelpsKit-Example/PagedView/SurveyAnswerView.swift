//
//  SurveyAnswerView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

extension SurveyAnswersQuery {
    @MainActor func pagedListViewModel(_ session: ParticipantSessionType) -> PagedViewModel<SurveyAnswersSource> {
        PagedViewModel(source: SurveyAnswersSource(session: session, query: self))
    }
}

struct SurveyAnswerView: View {
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
    
    @ObservedObject var model: Model
    let showSurveyDisplayName: Bool
    
    init(model: SurveyAnswerView.Model, showSurveyDisplayName: Bool = true) {
        self.model = model
        self.showSurveyDisplayName = showSurveyDisplayName
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                /// EXERCISE: Add or modify views here to see the values of other `SurveyAnswer` properties.
                Text(model.value)
                if showSurveyDisplayName {
                    Text(model.surveyDisplayName)
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                }
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
        List {
            SurveyAnswerView(model: .init(session: ParticipantSessionPreview(), id: .init("sa1"), surveyResultID: .init("sr1"), value: "Answer Value", date: Date(), surveyDisplayName: "Survey Name", deletionState: .notDeleted))
            SurveyAnswerView(model: .init(session: ParticipantSessionPreview(), id: .init("sa1"), surveyResultID: .init("sr1"), value: "Answer Value", date: Date(), surveyDisplayName: "Survey Name", deletionState: .deleted))
            SurveyAnswerView(model: .init(session: ParticipantSessionPreview(), id: .init("sa1"), surveyResultID: .init("sr1"), value: "Answer Value", date: Date(), surveyDisplayName: "Survey Name", deletionState: .failure(.unknown(nil))), showSurveyDisplayName: false)
        }
    }
}
