//
//  SurveyLauncherView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/13/23.
//

import SwiftUI
import MyDataHelpsKit

struct SurveyLauncherView: View {
    private struct SurveyLauncherLogItem: Identifiable {
        let id = UUID()
        let date: Date
        let surveyName: String
        let message: String
    }
    
    @ObservedObject var participant: ParticipantModel
    @FocusState private var surveyNameFocus: Bool
    
    @State private var surveyName = ""
    @State private var presentedSurvey: SurveyPresentation? = nil
    @State private var presentedSurveyResult: String? = nil
    @State private var log: [SurveyLauncherLogItem] = []
    
    var body: some View {
        Form {
            Section {
                Text("Enter a survey name to launch:")
                TextField("Survey Name", text: $surveyName)
                    .focused($surveyNameFocus)
                Button("Launch Survey", action: launchSurvey)
                    .font(.headline)
                    .disabled(surveyName.isEmpty)
            } footer: {
                Text("Choose a survey that’s published to your project in MyDataHelps Designer.")
            }
            
            if (!log.isEmpty) {
                Section {
                    ForEach(log.sorted { $0.date > $1.date }) { item in
                        VStack(alignment: .leading) {
                            Text(item.surveyName)
                                .font(.headline)
                            Text(item.message)
                                .font(.body)
                            Text(item.date.formatted(date: .omitted, time: .standard))
                                .font(.footnote)
                        }
                    }
                } header: {
                    Text("Log")
                }
            }
        }
        .navigationTitle("Survey Launcher")
        .onAppear {
            surveyNameFocus = true
        }
        .sheet(item: $presentedSurvey, onDismiss: {
            if let presentedSurveyResult {
                log.append(SurveyLauncherLogItem(date: Date(), surveyName: surveyName, message: presentedSurveyResult))
            }
            presentedSurveyResult = nil
        }, content: { presentation in
            PresentedSurveyView(presentation: $presentedSurvey, resultMessage: $presentedSurveyResult)
        })
    }
    
    private func launchSurvey() {
        // Ignore if using a stubbed session from a preview provider.
        guard let session = participant.session as? ParticipantSession else { return }
        
        guard !surveyName.isEmpty else { return }
        log.append(SurveyLauncherLogItem(date: Date(), surveyName: surveyName, message: "Presenting survey"))
        presentedSurvey = session.surveyPresentation(surveyName: surveyName)
    }
}

struct SurveyLauncherView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SurveyLauncherView(participant: ParticipantModel(session: ParticipantSessionPreview()))
        }
    }
}
