//
//  EmbeddableSurveyViewController.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 5/25/21.
//

import Foundation

#if canImport(UIKit)

import UIKit
import WebKit

/// Presents a MyDataHelps embeddable survey or task inside a web view. This view controller implements the complete user experience for a MyDataHelps survey, including step navigation, sending results to RKStudio, etc., and is intended for modal presentation.
///
/// ### Enabling MyDataHelps Embeddable Surveys in RKStudio
///
/// In order to use EmbeddableSurveyViewController to present a MyDataHelps embeddable survey, this feature must be enabled for both the project and the survey in RKStudio:
/// - Enable "Allow Survey Completion Via Link" in project settings.
/// - Enable "Allow Task Completion Via Link" and/or "Allow Survey Completion Via Link" in survey settings.
///
/// See [Completing Surveys with Survey Links](https://rkstudio-support.careevolution.com/hc/en-us/articles/360036515193-Completing-Surveys-with-Survey-Links) for more information.
///
/// ### Initializing and Presenting
///
/// Create an EmbeddableSurveyViewController using one of its `init` methods, identifying the participant by their `participantLinkIdentifier` and the survey or task by `surveyName` or `taskLinkIdentifier`.
///
/// For the best user experience, present this view controller modally, and do not wrap it in a UINavigationController, etc. The embedded survey content itself will display all of the controls necessary for navigation, such as localized Cancel/Done buttons.
///
/// ### Completion and Dismissal
///
/// Once the participant has finished interacting with the survey, EmbeddableSurveyViewController will invoke the `completion` callback. The view controller will not dismiss itself. In all cases—success and failure—your completion callback _must_ dismiss the EmbeddableSurveyViewController.
///
/// Use the `Result` object sent to the completion callback to determine whether the survey interaction was successful or failed. If the result is a `failure`, consider displaying an error alert to the user.
public final class EmbeddableSurveyViewController: UIViewController {
    private enum State {
        /// The web view is not yet loading the survey.
        case uninitialized
        /// The web view is loading the survey/DOM initialization is in process.
        case loading(WKNavigation?)
        /// Survey is presented on-screen and ready for user interaction.
        case ready
        /// User interaction is complete. Completion callback has been invoked
        case completed
    }
    
    private static let timeoutIntervalSeconds = 15
    private let surveyURL: Result<URL, MyDataHelpsError>
    private let languageTag: String
    private let userAgent: String
    private let completion: (Result<EmbeddableSurveyCompletionReason, MyDataHelpsError>) -> Void
    
    private var viewState: State
    
    /// Initializes an EmbeddableSurveyViewController that will display a survey task assigned to a participant.
    /// - Parameters:
    ///   - client: The client through which to access the embedded survey.
    ///   - taskLinkIdentifier: Identifies the survey task to present to the participant. This is the `linkIdentifier` property of `SurveyTask`, as retrieved via `ParticipantSession.querySurveyTasks`.
    ///   - participantLinkIdentifier: Auto-generated participant identifier used to complete surveys via link. This is the `linkIdentifier` property of `ParticipantInfo`, as retrieved via `ParticipantSession.getParticipantInfo`.
    ///   - completion: Called when the participant has completed interaction with the survey. The completion callback must always dismiss the EmbeddableSurveyViewController.
    public init(client: MyDataHelpsClient, taskLinkIdentifier: String, participantLinkIdentifier: String, completion: @escaping (Result<EmbeddableSurveyCompletionReason, MyDataHelpsError>) -> Void) {
        self.surveyURL = client.embeddableSurveyURL(taskLinkIdentifier: taskLinkIdentifier, participantLinkIdentifier: participantLinkIdentifier)
        self.languageTag = client.languageTag
        self.userAgent = client.userAgent
        self.completion = completion
        self.viewState = .uninitialized
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
    }
    
    /// Initializes an EmbeddableSurveyViewController that will display a survey identified by name.
    /// - Parameters:
    ///   - client: The client through which to access the embedded survey.
    ///   - surveyName: The name of the survey to present.
    ///   - participantLinkIdentifier: Auto-generated participant identifier used to complete surveys via link. This is the `linkIdentifier` property of `ParticipantInfo`, as retrieved via `ParticipantSession.getParticipantInfo`.
    ///   - completion: Called when the participant has completed interaction with the survey. The completion callback must always dismiss the EmbeddableSurveyViewController.
    public init(client: MyDataHelpsClient, surveyName: String, participantLinkIdentifier: String, completion: @escaping (Result<EmbeddableSurveyCompletionReason, MyDataHelpsError>) -> Void) {
        self.surveyURL = client.embeddableSurveyURL(surveyName: surveyName, participantLinkIdentifier: participantLinkIdentifier)
        self.languageTag = client.languageTag
        self.userAgent = client.userAgent
        self.completion = completion
        self.viewState = .uninitialized
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    public override func loadView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "SurveyWindowInitialized")
        contentController.add(self, name: "SurveyFinished")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.websiteDataStore = .nonPersistent()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.customUserAgent = userAgent
        
        view = webView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let webView = view as? WKWebView else { return }
        guard case .uninitialized = viewState else { return }
        
        switch surveyURL {
        case let .failure(error):
            complete(.failure(error))
        case let .success(url):
            let request = URLRequest(url: url)
            viewState = .loading(webView.load(request))
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Self.timeoutIntervalSeconds)) { [weak self] in
                self?.checkForLoadingTimeout()
            }
        }
    }
    
    private func checkForLoadingTimeout() {
        if case .loading = viewState {
            if let webView = view as? WKWebView {
                webView.stopLoading()
            }
            complete(.failure(.webContentError(nil)))
        }
    }
    
    private func complete(_ result: Result<EmbeddableSurveyCompletionReason, MyDataHelpsError>) {
        if case .completed = viewState { return }
        completion(result)
        viewState = .completed
    }
}

/// Describes how a participant completed interaction with an embeddable survey.
///
/// See `EmbeddableSurveyViewController` for usage; note that your app must dismiss the EmbeddableSurveyViewController in _all_ EmbeddableSurveyCompletionReason cases.
public struct EmbeddableSurveyCompletionReason: RawRepresentable, Equatable {
    public typealias RawValue = String
    
    /// Participant completed the survey, and the result was saved to RKStudio.
    public static let completed = EmbeddableSurveyCompletionReason(rawValue: "Completed")
    /// Participant did not complete the survey.
    public static let closed = EmbeddableSurveyCompletionReason(rawValue: "Closed")
    
    /// The raw value for the completion reason.
    public let rawValue: String
    
    /// Initializes a `EmbeddableSurveyCompletionReason` with an arbitrary value. Consider using static members such as `EmbeddableSurveyCompletionReason.completed` in equality checks or switch statements when inspecting completion reasons returned by embeddable surveys.
    /// - Parameter rawValue: The raw value for the completion reason.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension EmbeddableSurveyViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch (message.name, message.body) {
        case ("SurveyWindowInitialized", _):
            if case .loading = viewState {
                viewState = .ready
            }
        case let ("SurveyFinished", info as [String: Any]):
            if case .ready = viewState {
                if let reasonValue = info["reason"] as? String {
                    let completionReason = EmbeddableSurveyCompletionReason(rawValue: reasonValue)
                    complete(.success(completionReason))
                } else {
                    // This happens for some specific failure scenarios, e.g. if the
                    // survey name or task ID is invalid.
                    complete(.failure(.webContentError(nil)))
                }
            }
        default:
            break
        }
    }
}

extension EmbeddableSurveyViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if case .loading(navigation) = viewState {
            complete(.failure(.webContentError(error)))
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if case .loading(navigation) = viewState {
            complete(.failure(.webContentError(error)))
        }
    }
}

#endif

internal extension MyDataHelpsClient {
    func embeddableSurveyURL(taskLinkIdentifier: String, participantLinkIdentifier: String) -> Result<URL, MyDataHelpsError> {
        do {
            let url = try endpoint(path: "mydatahelps/\(participantLinkIdentifier)/tasklink/\(taskLinkIdentifier)", queryItems: [.init(name: "lang", value: languageTag)])
            return .success(url)
        } catch {
            return .failure(.encodingError(error))
        }
    }
    
    func embeddableSurveyURL(surveyName: String, participantLinkIdentifier: String) -> Result<URL, MyDataHelpsError> {
        do {
            let url = try endpoint(path: "mydatahelps/\(participantLinkIdentifier)/surveylink/\(surveyName)", queryItems: [.init(name: "lang", value: languageTag)])
            return .success(url)
        } catch {
            return .failure(.encodingError(error))
        }
    }
}
