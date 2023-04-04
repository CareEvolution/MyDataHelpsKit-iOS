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
        NavigationStack(path: $model.path) {
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
                
                if let ehrConnectionsEnabled = model.ehrConnectionsEnabled {
                    Section {
                        NavigationLink(value: ehrConnectionsEnabled ? AccountNavigationPath.externalAccounts : nil) {
                            Text("External Accounts")
                        }
                    } footer: {
                        if ehrConnectionsEnabled {
                            Text("View connected external accounts, and add provider connections.")
                        } else {
                            Text("EHR connection features are disabled for your project.")
                        }
                    }
                }
            }
            .refreshable {
                await model.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: ParticipantSession.participantDidUpdateNotification)) { _ in
                Task {
                    await model.refresh()
                }
            }
            .onAppear { model.loadData() }
            .navigationTitle(Self.tabTitle)
            .toolbar {
                ToolbarItemGroup(placement: .destructiveAction) {
                    Button("Log Out", role: .destructive, action: logOut)
                }
            }
            .navigationDestination(for: AccountNavigationPath.self) { destination in
                switch destination {
                case .externalAccounts:
                    ExternalAccountsListView(model: ExternalAccountsListViewModel(session: model.session))
                        .navigationTitle("External Accounts")
                    
                case .providerSearch:
                    /// EXERCISE: Modify the query parameters to customize filtering providers.
                    ExternalAccountProviderPagedView(model: ExternalAccountProvidersQuery(limit: 25).pagedListViewModel(model.session))
                        .navigationTitle("Connect to a Provider")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
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
