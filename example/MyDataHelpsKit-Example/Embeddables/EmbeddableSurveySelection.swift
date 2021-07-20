//
//  EmbeddableSurveySelection.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 6/3/21.
//

import Foundation
import MyDataHelpsKit

struct EmbeddableSurveySelection: Identifiable {
    let survey: EmbeddableSurveyID
    let participantLinkIdentifier: String
    
    var id: String {
        switch survey {
        case let .surveyName(name): return name
        case let .taskLinkIdentifier(name): return name
        }
    }
}

enum EmbeddableSurveyID: Identifiable {
    case surveyName(String)
    case taskLinkIdentifier(String)
    
    var id: String {
        switch self {
        case let .surveyName(name): return name
        case let .taskLinkIdentifier(name): return name
        }
    }
}

