//
//  ContentView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI

/// Root level of the app when the participant is logged in with a valid access token.
struct ContentView: View {
    let participant: ParticipantModel
    
    var body: some View {
        TabView {
            TasksView(model: TasksViewModel(session: participant.session))
                .tabItem {
                    Label(TasksView.tabTitle, systemImage: "checklist")
                }

            DataView(model: DataViewModel(session: participant.session))
                .tabItem {
                    Label(DataView.tabTitle, systemImage: "heart.text.square")
                }
            
            ActivityView(model: ActivityViewModel(session: participant.session))
                .tabItem {
                    Label(ActivityView.tabTitle, systemImage: "clock")
                }
            
            AccountView(model: AccountViewModel(participant: participant))
                .tabItem {
                    Label(AccountView.tabTitle, systemImage: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(participant: ParticipantModel(session: ParticipantSessionPreview(), info: PreviewData.participantInfo))
            .environmentObject(SessionModel())
    }
}
