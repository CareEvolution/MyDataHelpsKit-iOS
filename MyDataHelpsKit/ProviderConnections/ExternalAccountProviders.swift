//
//  ExternalAccountProviders.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/24/21.
//

import Foundation

public extension ParticipantSession {
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery, completion: @escaping (Result<[ExternalAccountProvider], MyDataHelpsError>) -> Void) {
        load(resource: ExternalAccountProvidersQueryResource(query: query), completion: completion)
    }
    
    /// finalRedirectURL could be a custom scheme or a universal link supported by your app. Either way, your AppDelegate or SwiftUI view must accept the incoming redirect URL or universal link, and dismiss the web view when that URL is received.
    func connectExternalAccount(provider: ExternalAccountProvider, finalRedirectURL: URL, completion: @escaping (Result<URL, MyDataHelpsError>) -> Void) {
        load(resource: ConnectExternalAccountResource(providerID: provider.id, finalRedirectURL: finalRedirectURL), completion: completion)
    }
}

/// Specifies filtering criteria for external account provider queries.
public struct ExternalAccountProvidersQuery {
    /// Limit search results to account providers whose keyword, postal code, city, or state begins with the search string. Case-insensitive.
    public let search: String?
    /// Limit search results to account providers with the specified category.
    public let category: ExternalAccountProviderCategory?
    
    /// Initializes a new query for external account providers with various filters.
    /// - Parameters:
    ///   - search: Limit search results to account providers whose keyword, postal code, city, or state begins with the search string. Case-insensitive.
    ///   - category: Limit search results to account providers with the specified category.
    public init(search: String? = nil, category: ExternalAccountProviderCategory? = nil) {
        self.search = search
        self.category = category
    }
}

public struct ExternalAccountProviderCategory: RawRepresentable, Equatable, Hashable, Decodable {
    public typealias RawValue = String
    
    public static let provider = ExternalAccountProviderCategory(rawValue: "Provider")
    public static let healthPlan = ExternalAccountProviderCategory(rawValue: "Health Plan")
    public static let deviceManufacturer = ExternalAccountProviderCategory(rawValue: "Device Manufacturer")
    
    /// The raw value for the provider category as stored in RKStudio.
    public let rawValue: String
    
    /// Initializes an `ExternalAccountProviderCategory` with an arbitrary value. Consider using static members such as `ExternalAccountProviderCategory.provider` instead for known values.
    /// - Parameter rawValue: The raw value for the provider category as stored in RKStudio.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct ExternalAccountProvider: Decodable {
    /// Assigned identifier for this external account provider.
    public let id: Int
    /// Name of the external account provider.
    public let name: String
    /// Type of account provider.
    public let category: ExternalAccountProviderCategory
    /// Full URL from which the logo can be retrieved, if one is available for the provider.
    public let logoUrl: URL?
}
