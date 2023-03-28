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
    
    private var projectInfo: Result<ProjectInfo, MyDataHelpsError>? = nil {
        didSet {
            updateProjectModel()
        }
    }
    
    private var dataCollectionSettings: Result<ProjectDataCollectionSettings, MyDataHelpsError>? = nil {
        didSet {
            updateProjectModel()
        }
    }
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func loadData() {
        Task {
            if case .some(.success) = participantInfo { return }
            participantInfo = await Result(wrapping: try await session.getParticipantInfo())
        }
        
        Task {
            if case .some(.success) = projectInfo { return }
            projectInfo = await Result(wrapping: try await session.getProjectInfo())
        }
        
        Task {
            if case .some(.success) = dataCollectionSettings { return }
            dataCollectionSettings = await Result(wrapping: try await session.getDataCollectionSettings())
        }
    }
    
    private func updateProjectModel() {
        switch (projectInfo, dataCollectionSettings) {
        case let (.some(.failure(error)), _):
            projectModel = .failure(error)
        case let (_, .some(.failure(error))):
            projectModel = .failure(error)
        case let (.some(.success(info)), .some(.success(settings))):
            projectModel = .success(.init(info: info, dataCollectionSettings: settings))
        default:
            projectModel = .none
        }
    }
}
