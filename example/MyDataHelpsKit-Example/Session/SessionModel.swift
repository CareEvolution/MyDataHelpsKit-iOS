//
//  SessionModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

class SessionModel: ObservableObject {
    let client: MyDataHelpsClient
    @Published var token: String = ""
    @Published var session: ParticipantSession? = nil
    
    init() {
         self.client = MyDataHelpsClient()
    }
    
    func authenticate() {
        session = ParticipantSession(client: client, accessToken: .init(token: token))
    }
    
    func logOut() {
        session = nil
    }
}
