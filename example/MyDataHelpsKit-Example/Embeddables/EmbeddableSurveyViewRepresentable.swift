//
//  EmbeddableSurveyViewRepresentable.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 5/25/21.
//

import SwiftUI
import MyDataHelpsKit

/// SwiftUI wrapper for MyDataHelpsKit.EmbeddableSurveyViewController.
struct EmbeddableSurveyViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @EnvironmentObject private var sessionModel: SessionModel
    let model: EmbeddableSurveySelection
    var presentation: Binding<EmbeddableSurveySelection?>
    var error: Binding<MyDataHelpsError?>
    
    func makeUIViewController(context: Context) -> UIViewController {
        return makeSurveyViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    private func makeSurveyViewController() -> UIViewController {
        let completion: (Result<EmbeddableSurveyCompletionReason, MyDataHelpsError>) -> Void = {
            if case let .failure(errorResult) = $0 {
                error.wrappedValue = errorResult
            } else {
                error.wrappedValue = nil
            }
            presentation.wrappedValue = nil
        }
        switch model.survey {
        case let .surveyName(surveyName):
            return EmbeddableSurveyViewController(client: sessionModel.client, surveyName: surveyName, participantLinkIdentifier: model.participantLinkIdentifier, completion: completion)
        case let .taskLinkIdentifier(taskLinkIdentifier):
            return EmbeddableSurveyViewController(client: sessionModel.client, taskLinkIdentifier: taskLinkIdentifier, participantLinkIdentifier: model.participantLinkIdentifier, completion: completion)
        }
    }
}

struct EmbeddableSurveyViewRepresentable_Previews: PreviewProvider {
    private struct ContainerView: View {
        @State var selection: EmbeddableSurveySelection? = nil
        @State var surveyError: MyDataHelpsError? = nil {
            didSet {
                errorModel = surveyError.map { .init(title: "Error", error: $0) }
            }
        }
        @State var errorModel: ErrorView.Model? = nil
        
        var body: some View {
            EmbeddableSurveyViewRepresentable(model: .init(survey: .surveyName(""), participantLinkIdentifier: .init("")), presentation: $selection, error: $surveyError)
                .alert(item: $errorModel) {
                    Alert(title: Text($0.error.localizedDescription))
                }
        }
    }
    
    static var previews: some View {
        ContainerView()
            .environmentObject(SessionModel())
    }
}
