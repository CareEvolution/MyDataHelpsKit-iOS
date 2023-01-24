//
//  ParticipantAccessToken.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

/// Represents an access token for a single participant.
///
/// See [documentation on Participant Tokens](https://developer.mydatahelps.org/embeddables/participant_tokens.html) for more information about obtaining an access token.
///
/// **Warning:** Never expose a service token in a client application or to the SDK. Use participant tokens instead.
public struct ParticipantAccessToken {
    
    /// The access token value. An opaque string.
    internal let token: String
    
    /// Initializes an access token with a given token value.
    /// - Parameter token: The token string, returned from an authentication provider.
    public init(token: String) {
        self.token = token
    }
}
