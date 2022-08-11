//
//  ParticipantModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

class ParticipantModel: ObservableObject {
    let session: ParticipantSessionType
    
    @Published var info: Result<ParticipantInfoViewModel, MyDataHelpsError>? = nil
    @Published var project: Result<ProjectInfo, MyDataHelpsError>? = nil
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func loadInfo() {
        if case .some(.success(_)) = info { return }
        session.getParticipantInfoViewModel { [weak self] result in
            self?.info = result
        }
    }
    
    func loadProject() {
        if case .some(.success) = project { return }
        session.getProjectInfo { [weak self] in
            self?.project = $0
        }
    }
}
