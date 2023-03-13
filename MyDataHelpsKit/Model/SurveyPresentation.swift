//
//  SurveyPresentation.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/8/23.
//

import Foundation
import RegexBuilder

extension ParticipantSession {
    /// Prepares a model object used for presenting a `SurveyViewController`. See ``SurveyViewController`` documentation for more information.
    /// - Parameter surveyName: The name of the survey to present. In MyDataHelps Designer, this survey must be published to the project the participant is interacting with.
    /// - Returns: A value that is used to initialize a ``SurveyViewController``.
    public func surveyPresentation(surveyName: String) -> SurveyPresentation {
        return SurveyPresentation(surveyName: surveyName, languageTag: client.languageTag, session: self)
    }
}

/// Information about a survey that should be presented to the participant.
///
/// See ``SurveyViewController`` documentation for more information.
public struct SurveyPresentation {
    /// The name of the survey to present.
    public let surveyName: String
    
    /// The language and region that will be used for the survey, if the survey is appropriately localized.
    ///
    /// An IETF language tag, such as `en-US`.
    public let languageTag: String
    
    fileprivate let session: ParticipantSession
    
    internal var baseURL: URL {
        session.client.baseURL
    }
    
    internal var userAgent: String {
        session.client.userAgent
    }
    
    private var embeddedSurveyURL: URL {
        get throws {
            try session.client.endpoint(path: "survey", queryItems: [
                .init(name: "surveyName", value: surveyName),
                .init(name: "lang", value: languageTag)
            ])
        }
    }
}

/// JavaScript -> WKWebView callbacks via `window.webkit.messageHandlers.<messageName>.postMessage()`.
internal enum SurveyMessageName: String, CaseIterable {
    case surveyWindowInitialized = "SurveyWindowInitialized"
    case surveyFinished = "SurveyFinished"
}

/// For embedding configuration data into the frame wrapper HTML.
///
/// Encode this to JSON to ensure safe encoding/escaping of user-entered values in a JavaScript context.
fileprivate struct SurveyFrameModel: Encodable {
    let frameURL: URL
    let baseURL: URL
    let accessToken: String
    let participantID: ParticipantInfo.ID
}

extension SurveyPresentation {
    internal func buildWrapperHTML() async throws -> String {
        let participantID = try await session.getParticipantInfo().participantID
        let model = SurveyFrameModel(frameURL: try embeddedSurveyURL, baseURL: session.client.baseURL, accessToken: session.accessToken.token, participantID: participantID)

        // Use JSON encoding to ensure user-entered values are safely encoded/escaped when embedded into JavaScript.
        let modelJSONText: String
        do {
            let modelJSON = try JSONEncoder.myDataHelpsEncoder.encode(model)
            guard let jsonString = String(data: modelJSON, encoding: .utf8) else {
                throw EncodingError.invalidValue(modelJSON, EncodingError.Context(codingPath: [], debugDescription: "Failed to encode survey configuration"))
            }
            modelJSONText = jsonString
        } catch {
            throw MyDataHelpsError.encodingError(error)
        }
        
        // languageTag is embedded as an HTML attribute so it needs to be cleaned separately from the JSON object above.
        let languageTagFilter = CharacterSet.alphanumerics.union(.init(charactersIn: "-"))
        let languageTagAttribute = String(languageTag.unicodeScalars.filter { languageTagFilter.contains($0) })
        
        return """
<!DOCTYPE html>
<html lang="\(languageTagAttribute)">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
        }
        iframe#mydatahelps-survey-frame {
            position: absolute;
            left: 0;
            top: 0;
            right: 0;
            bottom: 0;
            width: 100%;
            height: 100%;
            border: none;
        }
        #debugLog {
            display: none;
        }
    </style>
</head>
<body><iframe id='mydatahelps-survey-frame' allow='camera' sandbox='allow-forms allow-modals allow-popups allow-popups-to-escape-sandbox allow-presentation allow-same-origin allow-scripts' src='' frameBorder="0"></iframe>

<script>
    let model = \(modelJSONText);
    window.addEventListener('message', function listener(message) {
         if (message.origin !== new URL(model.baseURL).origin) {
             return;
         }
         let frame = document.getElementById('mydatahelps-survey-frame').contentWindow;
         if (message.source !== frame) {
             return;
         }
         if (message.data.name === 'GetDelegatedAccessToken') {
             frame.postMessage({ name: "DelegatedAccessTokenResponse", accessToken: {"access_token": model.accessToken}, baseUrl: model.baseURL, participantID: model.participantID }, '*');
         } else if (message.data.name === '\(SurveyMessageName.surveyWindowInitialized.rawValue)') {
             window.webkit.messageHandlers.\(SurveyMessageName.surveyWindowInitialized.rawValue).postMessage(true);
         } else if (message.data.name === '\(SurveyMessageName.surveyFinished.rawValue)') {
             window.webkit.messageHandlers.\(SurveyMessageName.surveyFinished.rawValue).postMessage(message.data.reason);
         }
     }, true);

    document.querySelector('#mydatahelps-survey-frame').src = model.frameURL;
</script></body></html>
"""
    }
}
