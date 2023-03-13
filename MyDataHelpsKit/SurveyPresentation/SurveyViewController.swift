//
//  SurveyViewController.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 1/19/23.
//

import Foundation

#if canImport(UIKit)

import UIKit
import WebKit
import SafariServices

/// Presents a MyDataHelps survey inside a web view. This view controller implements the complete user experience for a MyDataHelps survey, including step navigation and sending results to MyDataHelps, and is intended for modal presentation.
///
/// Surveys are presented to the participant are identified by the [survey name](https://support.mydatahelps.org/hc/en-us/articles/360020984114). The survey must be [published to the project](https://support.mydatahelps.org/hc/en-us/articles/4882070156051-Survey-Versioning-and-Publishing) that the participant is currently interacting with.
///
/// SurveyViewController is not intended for subclassing.
///
/// ### Initializing and Presenting
///
/// 1. Call `ParticipantSession.surveyPresentation(surveyName:)` to construct a model object for the survey you wish to present.
/// 2. Construct a `SurveyViewController` using the `init(presentation:, completion:)` initializer.
/// 3. Present the view controller to the participant. SurveyViewControllers are intended to be shown modally, e.g. using `present(surveyViewController, animated: true)` in UIKit or a `.sheet` presentation in SwiftUI.
///
/// Do not wrap the SurveyViewController with a UINavigationController or NavigationView or embed it inside another view controller. MyDataHelpsKit handles all navigation elements and controls internally, including localized Cancel/Done buttons.
///
/// ### Completion and Dismissal
///
/// Once the participant has finished interacting with the survey, or if there is a failure to present the survey, SurveyViewController will invoke the `completion` callback you passed to its initializer. The SurveyViewController will not dismiss itself. In all cases—success and failure—you _must_ dismiss the SurveyViewController yourself from the completion callback.
///
/// The completion callback includes a `Result` value that indicates whether the participant successfully completed the survey, and any error that may have been encountered. If the result is a `failure`, consider displaying an error alert to the user.
public final class SurveyViewController: UIViewController {
    
    /// Describes how a participant completed interaction with a survey.
    ///
    /// See ``SurveyViewController`` for usage; note that your app must dismiss the SurveyViewController in _all_ result cases.
    public enum SurveyResult: String {
        /// Participant completed the survey, and the result was saved to MyDataHelps.
        case completed = "Completed"
        /// Participant did not complete the survey, and the results were discarded.
        case discarded = "Discarded"
    }
    
    private enum State {
        /// Initial state. Fetching data necessary to initialize web view.
        case unloaded
        /// Web view and other views created, waiting for surveyWindowInitialized event.
        case loadingContent
        /// Received surveyWindowInitialized event. User can interact with survey.
        case activeContent
        /// Timed out or got completion. Called callback. No longer interactive. Should be dismissed.
        case finished
    }
    
    /// WKUserContentController maintains a strong reference to its WKScriptMessageHandlers, which can easily cause a retain cycle. This simple wrapper breaks the retain cycle.
    private class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
        private unowned let delegate: WKScriptMessageHandler
        
        init(delegate: WKScriptMessageHandler, userContentController: WKUserContentController) {
            self.delegate = delegate
            super.init()
            for name in SurveyMessageName.allCases {
                userContentController.add(self, name: name.rawValue)
            }
        }
        
        func removeMessageHandlers(_ userContentController: WKUserContentController) {
            for name in SurveyMessageName.allCases {
                userContentController.removeScriptMessageHandler(forName: name.rawValue)
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            delegate.userContentController(userContentController, didReceive: message)
        }
    }
    
    private static let timeoutIntervalSeconds = 15
    
    /// Information about the survey being presented to the participant.
    public let presentation: SurveyPresentation
    
    private let completion: (SurveyViewController, Result<SurveyResult, MyDataHelpsError>) -> Void
    private var viewState: State
    private var messageHandler: ScriptMessageHandler?
    private var activityIndicator: UIActivityIndicatorView?
    private var webView: WKWebView?
    
    /// Initializes a SurveyViewController that presents a given survey to a participant.
    /// - Parameters:
    ///   - presentation: Information about the survey being presented to the participant. Construct this using `ParticipantSession.surveyPresentation(surveyName:)`.
    ///   - completion: Called when the participant has completed interaction with the survey. The completion callback must always dismiss the SurveyViewController.
    public init(presentation: SurveyPresentation, completion: @escaping (SurveyViewController, Result<SurveyResult, MyDataHelpsError>) -> Void) {
        self.presentation = presentation
        self.completion = completion
        self.viewState = .unloaded
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        if let webView {
            messageHandler?.removeMessageHandlers(webView.configuration.userContentController)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    private func setState(_ newState: State, if precondition: State) -> Bool {
        guard viewState == precondition else {
            return false
        }
        viewState = newState
        return true
    }
    
    private func setState(_ newState: State, ifNot precondition: State) -> Bool {
        guard viewState != precondition else {
            return false
        }
        viewState = newState
        return true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
            indicator.startAnimating()
            return indicator
        }()
        
        (self.webView, self.messageHandler) = {
            let config = WKWebViewConfiguration()
            let messageHandler = ScriptMessageHandler(delegate: self, userContentController: config.userContentController)
            let webView = WKWebView(frame: view.bounds, configuration: config)
            webView.allowsBackForwardNavigationGestures = false
            webView.allowsLinkPreview = false
            webView.customUserAgent = presentation.userAgent
            webView.navigationDelegate = self
            
            webView.isHidden = true // Hide until the content is loaded.
            webView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(webView)
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            return (webView, messageHandler)
        }()
        
        loadEmbeddedSurvey()
    }
    
    private func loadEmbeddedSurvey() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let html = try await self.presentation.buildWrapperHTML()
                self.loadIframe(html: html)
            } catch let error as MyDataHelpsError {
                complete(.failure(error))
            } catch {
                complete(.failure(.unknown(error)))
            }
        }
    }
    
    private func loadIframe(html: String) {
        assert(Thread.isMainThread)
        guard let webView else { return }
        guard setState(.loadingContent, if: .unloaded) else { return }
        webView.loadHTMLString(html, baseURL: presentation.baseURL)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Self.timeoutIntervalSeconds)) { [weak self] in
            self?.checkIframeTimeout()
        }
    }
    
    private func checkIframeTimeout() {
        if viewState == .loadingContent {
            complete(.failure(.timedOut(MyDataHelpsError.unknown(nil))))
        }
    }
    
    private func complete(_ result: Result<SurveyResult, MyDataHelpsError>) {
        assert(Thread.isMainThread)
        // Ensure only a single completion callback.
        guard setState(.finished, ifNot: .finished) else { return }
        completion(self, result)
    }
    
    private func presentSafariView(url: URL) {
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.modalPresentationStyle = .pageSheet
        present(safari, animated: true)
    }
}

extension SurveyViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch SurveyMessageName(rawValue: message.name) {
        case .surveyWindowInitialized:
            guard setState(.activeContent, if: .loadingContent) else { return }
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
            webView?.isHidden = false
        case .surveyFinished:
            guard let rawResult = message.body as? String else {
                // If the survey name is invalid, SurveyFinished is invoked with a nil message.body.
                return complete(.failure(.invalidSurvey))
            }
            if let reason = SurveyResult(rawValue: rawResult) {
                complete(.success(reason))
            } else {
                complete(.failure(.webContentError(nil)))
            }
        default:
            assertionFailure("Unhandled script message \(message.name)")
        }
    }
}

extension SurveyViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        // Plain web links opened by user within the survey's content frame.
        if navigationAction.navigationType == .linkActivated,
           !navigationAction.sourceFrame.isMainFrame,
           let url = navigationAction.request.url,
           navigationAction.request.httpMethod == "GET",
           url.scheme == "https" {
            presentSafariView(url: url)
            return .cancel
        }
        return .allow
    }
}

#endif
