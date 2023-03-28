//
//  AccountView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

struct AccountView: View {
    static let tabTitle = "Account"
    
    @EnvironmentObject var session: SessionModel
    @StateObject var model: AccountViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section("Participant:") {
                    AsyncCardView(result: model.participantInfo, failureTitle: "Failed to load participant info") {
                        ParticipantInfoView(model: .init(info: $0))
                    }
                }
                Section("Enrolled in:") {
                    AsyncCardView(result: model.projectModel, failureTitle: "Failed to load project info") {
                        ProjectInfoView(project: $0.info, dataCollectionSettings: $0.dataCollectionSettings)
                    }
                }
            }
            .navigationTitle(Self.tabTitle)
            .toolbar {
                ToolbarItemGroup(placement: .destructiveAction) {
                    Button("Log Out", role: .destructive, action: logOut)
                }
            }
            .onAppear { model.loadData() }
        }
    }
    
    private func logOut() {
        session.logOut()
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(model: AccountViewModel(session: ParticipantSessionPreview()))
            .environmentObject(SessionModel())
    }
}
