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
    let participantLinkIdentifier: ParticipantLink.ID
    
    var id: String {
        switch survey {
        case let .surveyName(name): return name
        case let .taskLinkIdentifier(id): return id.value
        }
    }
}

enum EmbeddableSurveyID: Identifiable {
    case surveyName(String)
    case taskLinkIdentifier(SurveyTaskLink.ID)
    
    var id: String {
        switch self {
        case let .surveyName(name): return name
        case let .taskLinkIdentifier(id): return id.value
        }
    }
}

