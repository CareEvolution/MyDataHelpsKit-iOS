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
    @EnvironmentObject private var messageBanner: MessageBannerModel
    
    let presentation: Binding<SurveyPresentation?>
    
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
            defer {
                NotificationCenter.default.post(name: ParticipantSession.participantDidUpdateNotification, object: nil)
            }
            self.presentation.wrappedValue = nil
            
            let message: String
            switch result {
            case let .success(reason):
                switch reason {
                case .completed:
                    message = "Completed"
                case .discarded:
                    message = "Discarded"
                case .saved:
                    message = "Saved Progress"
                }
            case let .failure(error):
                message = error.localizedDescription
            }
            messageBanner(message)
        }
        return viewController
    }
}
