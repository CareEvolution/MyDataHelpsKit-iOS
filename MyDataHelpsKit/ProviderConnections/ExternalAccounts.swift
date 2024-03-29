//
//  ExternalAccounts.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/25/21.
//

import Foundation

public extension ParticipantSession {
    /// Fetches a list of all of the participant's connected external accounts.
    /// - Returns: An asynchronously-delivered list of connected counts, if successful. Throws a `MyDataHelpsError` if unsuccessful.
    func listExternalAccounts() async throws -> [ExternalAccount] {
        try await load(resource: ExternalAccountsResource())
    }
    
    /// Requests the refresh of data from a connected external account.
    ///
    /// This API only begins the process of refreshing an account; the process may take additional time to complete. To track the status of a refresh, use `ParticipantSession.listExternalAccounts` to poll the `status` value of an account, checking for `fetchingData` or `fetchComplete` status values.
    /// - Parameters:
    ///   - id: The ID of the external account to refresh.
    func refreshExternalAccount(_ id: ExternalAccount.ID) async throws {
        try await load(resource: RefreshExternalAccountResource(id: id))
    }
    
    /// Deletes an external account.
    ///
    /// This API is idempotent: the result will indicate success even if the account was already disconnected, or the participant had no such account.
    /// - Parameters:
    ///   - account: The ID of the external account to disconnect.
    func deleteExternalAccount(_ id: ExternalAccount.ID) async throws {
        try await load(resource: DeleteExternalAccountResource(id: id))
    }
}

/// Describes the status of fetching data for a connected external account.
public struct ExternalAccountStatus: RawRepresentable, Equatable, Hashable, Codable {
    public typealias RawValue = String
    
    /// An error occurred while fetching data.
    public static let error = ExternalAccountStatus(rawValue: "error")
    /// The connected external account has successfully retrieved data.
    public static let fetchComplete = ExternalAccountStatus(rawValue: "fetchComplete")
    /// The connected external account is in the process of fetching data.
    public static let fetchingData = ExternalAccountStatus(rawValue: "fetchingData")
    /// The external account connection was attempted, but not yet authorized.
    public static let unauthorized = ExternalAccountStatus(rawValue: "unauthorized")
    
    /// The raw value for the provider category as stored in MyDataHelps.
    public let rawValue: String
    
    /// Initializes an `ExternalAccountStatus` with an arbitrary value. Consider using static members such as `ExternalAccountStatus.fetchComplete` instead for known values.
    /// - Parameter rawValue: The raw value for the account status as stored in MyDataHelps.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// An external account that the participant is currently connected to.
public struct ExternalAccount: Identifiable, Decodable {
    /// Assigned identifier for an ExternalAccount.
    public typealias ID = ScopedIdentifier<ExternalAccount, Int>
    
    /// Assigned identifier for this connected external account.
    public let id: ID
    /// The current status for this connected external account.
    public let status: ExternalAccountStatus
    /// The provider for this external account.
    public let provider: ExternalAccountProvider
    /// Date when the account last successfully refreshed.
    public let lastRefreshDate: Date?
}
