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
    /// SurveyPresentation must be Identifiable for use in SwiftUI `.sheet` presentation.
    public var id: String { surveyName }
}

/// SwiftUI wrapper for MyDataHelpsKit.SurveyViewController.
struct PresentedSurveyView: UIViewControllerRepresentable {
    let presentation: Binding<SurveyPresentation?>
    let resultMessage: Binding<String?>?
    
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
                    resultMessage?.wrappedValue = "Completed"
                case .discarded:
                    resultMessage?.wrappedValue = "Discarded"
                case .saved:
                    resultMessage?.wrappedValue = "Saved Progress"
                }
            case let .failure(error):
                resultMessage?.wrappedValue = error.localizedDescription
            }
        }
        return viewController
    }
}
