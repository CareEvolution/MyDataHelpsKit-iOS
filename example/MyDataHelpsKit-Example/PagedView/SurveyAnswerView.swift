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
        let stepIdentifier: String
        let resultIdentifier: String
        let value: String
        let date: Date?
        let surveyDisplayName: String
        
        @Published var deletionState = DeletionState.notDeleted
        
        init(session: ParticipantSessionType, id: SurveyAnswer.ID, surveyResultID: SurveyResult.ID, stepIdentifier: String, resultIdentifier: String, value: String, date: Date?, surveyDisplayName: String, deletionState: DeletionState = .notDeleted) {
            self.session = session
            self.id = id
            self.surveyResultID = surveyResultID
            self.stepIdentifier = stepIdentifier
            self.resultIdentifier = resultIdentifier
            self.value = value
            self.date = date
            self.surveyDisplayName = surveyDisplayName
            self.deletionState = deletionState
        }
        
        init(session: ParticipantSessionType, answer: SurveyAnswer) {
            self.session = session
            self.id = answer.id
            self.surveyResultID = answer.surveyResultID
            self.stepIdentifier = answer.stepIdentifier
            self.resultIdentifier = answer.resultIdentifier
            self.value = answer.answers.joined(separator: ", ")
            self.date = answer.date
            self.surveyDisplayName = answer.surveyDisplayName
            self.deletionState = .notDeleted
        }
        
        func delete() async throws {
            guard case .notDeleted = deletionState else { return }
            do {
                try await session.deleteSurveyResult(surveyResultID)
                deletionState = .deleted
                NotificationCenter.default.post(name: ParticipantSession.participantDidUpdateNotification, object: nil)
            } catch {
                deletionState = .failure(MyDataHelpsError(error))
                throw error
            }
        }
    }
    
    @EnvironmentObject private var messageBanner: MessageBannerModel
    
    @ObservedObject var model: Model
    let showSurveyDisplayName: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                /// EXERCISE: Add or modify views here to see the values of other `SurveyAnswer` properties.
                Text(model.value)
                    .lineLimit(nil)
                Text(context(surveyDisplayName: model.surveyDisplayName, stepIdentifier: model.stepIdentifier, resultIdentifier: model.resultIdentifier))
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                    .lineLimit(nil)
            }
            Spacer()
            switch model.deletionState {
            case .notDeleted:
                Button(action: deleteAnswer, label: {
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
    
    private func context(surveyDisplayName: String, stepIdentifier: String, resultIdentifier: String) -> String {
        var tokens: [String] = []
        if showSurveyDisplayName {
            tokens.append(surveyDisplayName)
        }
        
        tokens.append(stepIdentifier)
        
        // Only some steps, such as form steps, have a resultIdentifier != stepIdentifier, to identify multiple results on a single step.
        if resultIdentifier != stepIdentifier {
            tokens.append(resultIdentifier)
        }
        return tokens.joined(separator: " > ")
    }
    
    var deletionStateColor: Color? {
        if case .deleted = model.deletionState {
            return Color(.systemGray)
        }
        return nil
    }
    
    private func deleteAnswer() {
        Task {
            do {
                try await model.delete()
                messageBanner("Deleted Answer")
            } catch {
                messageBanner(MyDataHelpsError(error).localizedDescription)
            }
        }
    }
}

struct SurveyAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SurveyAnswerView(model: .init(session: ParticipantSessionPreview(), id: .init("sa1"), surveyResultID: .init("sr1"), stepIdentifier: "Step1", resultIdentifier: "Step1", value: "Answer Value 1", date: Date(), surveyDisplayName: "Survey Name", deletionState: .notDeleted), showSurveyDisplayName: true)
            SurveyAnswerView(model: .init(session: ParticipantSessionPreview(), id: .init("sa1"), surveyResultID: .init("sr1"), stepIdentifier: "Step2", resultIdentifier: "FormItem1", value: "Answer Value 2", date: Date(), surveyDisplayName: "Survey Name", deletionState: .deleted), showSurveyDisplayName: true)
            SurveyAnswerView(model: .init(session: ParticipantSessionPreview(), id: .init("sa1"), surveyResultID: .init("sr1"), stepIdentifier: "Step2", resultIdentifier: "FormItem2", value: "Answer Value 3", date: Date(), surveyDisplayName: "Survey Name", deletionState: .failure(.unknown(nil))), showSurveyDisplayName: false)
        }
        .banner()
    }
}
