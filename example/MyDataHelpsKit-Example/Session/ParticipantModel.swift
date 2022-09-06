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
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func loadInfo() {
        if case .some(.success(_)) = info { return }
        Task {
            info = await Result(wrapping: try await session.getParticipantInfoViewModel())
        }
    }
}
