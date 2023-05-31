//
//  PersistentSurveysSectionView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 4/4/23.
//

import SwiftUI
import MyDataHelpsKit

struct PersistentSurveysSectionView: View {
    let session: ParticipantSessionType
    let persistentSurveys: [PersistentSurvey]
    var presentedSurvey: Binding<SurveyPresentation?>
    
    var body: some View {
        Section {
            ForEach(persistentSurveys) { survey in
                Button(survey.surveyDisplayName) {
                    launchSurvey(surveyName: survey.surveyName)
                }
                .buttonStyle(.plain)
            }
            if persistentSurveys.isEmpty {
                Text("EXERCISE: populate var persistentSurveys")
            }
            NavigationLink("Launch Another Survey", value: TasksNavigationPath.surveyLauncher)
        } footer: {
            Text("These surveys are presented by name, with no assigned task necessary.")
        }
    }
    
    private func launchSurvey(surveyName: String) {
        guard let session = session as? ParticipantSession else { return }
        presentedSurvey.wrappedValue = session.surveyPresentation(surveyName: surveyName)
    }
}

struct PersistentSurveysSectionView_Previews: PreviewProvider {
    @State private static var presentedSurvey: SurveyPresentation? = nil
    
    static var previews: some View {
        NavigationStack {
            List {
                PersistentSurveysSectionView(session: ParticipantSessionPreview(), persistentSurveys: [
                    PersistentSurvey(surveyName: "EMA1", surveyDisplayName: "Daily Mood Survey"),
                    PersistentSurvey(surveyName: "EMA2", surveyDisplayName: "Daily Medication Survey")
                ], presentedSurvey: $presentedSurvey)
            }
        }
    }
}
