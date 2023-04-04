//
//  SessionModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

/// Produces a `ParticipantSession` object with a `ParticipantAccessToken` manually entered into the UI. See [documentation on Participant Tokens](https://developer.mydatahelps.org/embeddables/participant_tokens.html) for information about obtaining an access token.
@MainActor class SessionModel: ObservableObject {
    let client: MyDataHelpsClient
    @Published var token: String = ""
    
    /// Non-nil once successfully authenticated with a valid token.
    @Published var participant: ParticipantModel? = nil
    
    init() {
        self.client = MyDataHelpsClient()
        if !token.isEmpty {
            Task {
                try? await authenticate()
            }
        }
    }
    
    func authenticate() async throws {
        let session = ParticipantSession(client: client, accessToken: .init(token: token))
        participant = ParticipantModel(session: session, info: try await session.getParticipantInfo())
    }
    
    func logOut() {
        participant = nil
    }
}
