//
//  ParticipantModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

@MainActor class ParticipantModel: ObservableObject {
    let session: ParticipantSessionType
    
    @Published var info: Result<ParticipantInfoViewModel, MyDataHelpsError>? = nil
    @Published var project: Result<ProjectInfo, MyDataHelpsError>? = nil
    @Published var dataCollectionSettings: Result<ProjectDataCollectionSettings, MyDataHelpsError>? = nil
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func loadInfo() {
        if case .some(.success(_)) = info { return }
        Task {
            info = await Result(wrapping: try await session.getParticipantInfoViewModel())
        }
    }
    
    func loadProject() {
        if case .some(.success) = project { return }
        Task {
            project = await Result(wrapping: try await session.getProjectInfo())
        }
    }
    
    func loadDataCollectionSettings() {
        if case .some(.success) = dataCollectionSettings { return }
        Task {
            dataCollectionSettings = await Result(wrapping: try await session.getDataCollectionSettings())
        }
    }
}
