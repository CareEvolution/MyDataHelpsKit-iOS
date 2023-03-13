//
//  PresentedSurveyView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/10/23.
//

import SwiftUI
import UIKit
import MyDataHelpsKit

extension SurveyPresentation: Identifiable {
    public var id: String { surveyName }
}

struct PresentedSurveyView: UIViewControllerRepresentable {
    let presentation: Binding<SurveyPresentation?>
    let resultMessage: Binding<String?>
    
    func makeUIViewController(context: Context) -> UIViewController {
        return makeSurveyViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    private func makeSurveyViewController() -> UIViewController {
        guard let model = presentation.wrappedValue else {
            // Should never happen.
            return UIViewController()
        }
        
        let viewController = SurveyViewController(presentation: model) { vc, result in
            self.presentation.wrappedValue = nil
            switch result {
            case let .success(reason):
                switch reason {
                case .completed:
                    resultMessage.wrappedValue = "Completed"
                case .discarded:
                    resultMessage.wrappedValue = "Discarded"
                }
            case let .failure(error):
                resultMessage.wrappedValue = error.localizedDescription
            }
        }
        return viewController
    }
}
