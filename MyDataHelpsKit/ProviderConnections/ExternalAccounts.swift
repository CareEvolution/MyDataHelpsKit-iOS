//
//  ExternalAccounts.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/25/21.
//

import Foundation

public extension ParticipantSession {
    /// Fetches a list of all of the participant's connected external accounts.
    func listExternalAccounts(completion: @escaping (Result<[ExternalAccount], MyDataHelpsError>) -> Void) {
        load(resource: ExternalAccountsResource(), completion: completion)
    }
}

public struct ExternalAccountStatus: RawRepresentable, Equatable, Hashable, Decodable {
    public typealias RawValue = String
    
    /// An error occurred while fetching data.
    public static let error = ExternalAccountStatus(rawValue: "Error")
    /// The connected external account has successfully retrieved data.
    public static let fetchComplete = ExternalAccountStatus(rawValue: "FetchComplete")
    /// The connected external account is in the process of fetching data.
    public static let fetchingData = ExternalAccountStatus(rawValue: "FetchingData")
    /// The external account connection was attempted, but not yet authorized.
    public static let unauthorized = ExternalAccountStatus(rawValue: "Unauthorized")
    
    /// The raw value for the provider category as stored in RKStudio.
    public let rawValue: String
    
    /// Initializes an `ExternalAccountProviderCategory` with an arbitrary value. Consider using static members such as `ExternalAccountProviderCategory.provider` instead for known values.
    /// - Parameter rawValue: The raw value for the provider category as stored in RKStudio.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// An external account that the participant is currently connected to.
public struct ExternalAccount: Decodable {
    /// Assigned identifier for this connected external account.
    public let id: Int
    /// The current status for this connected external account.
    public let status: ExternalAccountStatus
    /// The provider for this external account.
    public let provider: ExternalAccountProvider
    /// Date when the account last successfully refreshed.
    public let lastRefreshDate: Date?
}
