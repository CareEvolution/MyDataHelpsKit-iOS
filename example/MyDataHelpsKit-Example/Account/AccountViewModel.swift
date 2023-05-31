//
//  AccountViewModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

enum AccountNavigationPath: Codable, Hashable {
    case externalAccounts
    case providerSearch
}

@MainActor class AccountViewModel: ObservableObject {
    struct ProjectAndDataCollectionModel {
        let info: ProjectInfo
        let dataCollectionSettings: ProjectDataCollectionSettings
    }
    
    let participant: ParticipantModel
    @Published var path = NavigationPath()
    @Published var participantInfo: RemoteResult<ParticipantInfo> = .loading
    @Published var projectModel: RemoteResult<ProjectAndDataCollectionModel> = .loading
    @Published var ehrConnectionsEnabled: Bool? = nil
    
    var session: ParticipantSessionType { participant.session }
    
    init(participant: ParticipantModel) {
        self.participant = participant
        self.participantInfo = .success(participant.info)
    }
    
    func loadData() {
        Task {
            await loadParticipantInfo(force: false)
        }
        
        Task {
            await loadProjectModel(force: false)
        }
    }
    
    func refresh() async {
        await loadParticipantInfo(force: true)
        await loadProjectModel(force: true)
    }
    
    private func loadParticipantInfo(force: Bool) async {
        if case .success = participantInfo {
            guard force else { return }
        }
        participantInfo = await RemoteResult(wrapping: try await session.getParticipantInfo())
    }
    
    private func loadProjectModel(force: Bool) async {
        if case .success = projectModel {
            guard force else { return }
        }
        do {
            let info = try await session.getProjectInfo()
            let dataCollectionSettings = try await session.getDataCollectionSettings()
            projectModel = .success(.init(info: info, dataCollectionSettings: dataCollectionSettings))
            ehrConnectionsEnabled = dataCollectionSettings.ehrEnabled
        } catch {
            projectModel = .failure(MyDataHelpsError(error))
            ehrConnectionsEnabled = nil
        }
    }
}
