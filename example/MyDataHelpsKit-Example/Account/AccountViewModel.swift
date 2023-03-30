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
    
    let session: ParticipantSessionType
    @Published var path = NavigationPath()
    @Published var participantInfo: RemoteResult<ParticipantInfo> = .loading
    @Published var projectModel: RemoteResult<ProjectAndDataCollectionModel> = .loading
    @Published var ehrConnectionsEnabled: Bool? = nil
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func loadData() {
        Task {
            if case .success = participantInfo { return }
            participantInfo = await RemoteResult(wrapping: try await session.getParticipantInfo())
        }
        
        Task {
            if case .success = projectModel { return }
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
}
