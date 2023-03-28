//
//  AccountViewModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

@MainActor class AccountViewModel: ObservableObject {
    struct ProjectAndDataCollectionModel {
        let info: ProjectInfo
        let dataCollectionSettings: ProjectDataCollectionSettings
    }
    
    private let session: ParticipantSessionType
    @Published var participantInfo: Result<ParticipantInfo, MyDataHelpsError>? = nil
    @Published var projectModel: Result<ProjectAndDataCollectionModel, MyDataHelpsError>? = nil
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func loadData() {
        Task {
            if case .some(.success) = participantInfo { return }
            participantInfo = await Result(wrapping: try await session.getParticipantInfo())
        }
        
        Task {
            if case .some(.success) = projectModel { return }
            do {
                let info = try await session.getProjectInfo()
                let dataCollectionSettings = try await session.getDataCollectionSettings()
                projectModel = .success(.init(info: info, dataCollectionSettings: dataCollectionSettings))
            } catch {
                projectModel = .failure(MyDataHelpsError(error))
            }
        }
    }
}
