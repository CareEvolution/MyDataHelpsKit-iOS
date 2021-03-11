//
//  SessionModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

class SessionModel: ObservableObject {
    @Published var token: String = ""
    @Published var session: ParticipantSession? = nil
    
    func authenticate() {
        let client = MyDataHelpsClient()
        session = ParticipantSession(client: client, accessToken: .init(token: token))
    }
    
    func logOut() {
        session = nil
    }
}
