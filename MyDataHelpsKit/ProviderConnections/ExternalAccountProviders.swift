//
//  ExternalAccountProviders.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/24/21.
//

import Foundation

public extension ParticipantSession {
    /// Query the list of external account providers supported by MyDataHelps.
    ///
    /// To fetch the first page of results, call this with a new ``ExternalAccountProvidersQuery`` object. If there are additional pages available, the next page can be fetched by using `ExternalAccountProvidersQuery.page(after:)` to construct a query for the following page.
    /// - Parameters:
    ///   - query: Specifies how to filter the providers.
    /// - Returns: An asynchronously-delivered `ExternalAccountProvidersResultPage`, if successful. Throws a `MyDataHelpsError` if unsuccessful. Results are ordered by name.
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery) async throws -> ExternalAccountProvidersResultPage {
        let response = try await load(resource: ExternalAccountProvidersQueryResource(query: query))
        return ExternalAccountProvidersResultPage(result: response, query: query)
    }
    
    /// Initiates a new connected external account. Grants access to a secure OAuth connection to the specified external account provider, where the participant can provide their provider credentials and authorize MyDataHelps to retrieve data from the account.
    ///
    /// After receiving the `ExternalAccountAuthorization` returned by this function, your app must present an `SFSafariViewController` to the user using the `authorizationURL` in the returned object to complete the provider authorization flow.
    ///
    /// See [External Account Connections](https://developer.mydatahelps.org/ios/external_account_connections.html) for a detailed guide to implementing this feature in your app.
    ///
    /// - Parameters:
    ///   - providerID: The ID of the external account provider to connect.
    ///   - finalRedirectURL: A URL that is configured to open your app via a custom scheme or Universal Link.
    /// - Returns: An asynchronously-delivered `ExternalAccountAuthorization`, with the provider authorization URL and supporting information, if successful. Throws a `MyDataHelpsError` if unsuccessful.
    func connectExternalAccount(providerID: ExternalAccountProvider.ID, finalRedirectURL: URL) async throws -> ExternalAccountAuthorization {
        let authorizationURL = try await load(resource: ConnectExternalAccountResource(providerID: providerID, finalRedirectURL: finalRedirectURL))
        return ExternalAccountAuthorization(providerID: providerID, authorizationURL: authorizationURL, finalRedirectURL: finalRedirectURL)
    }
}

/// Specifies filtering and page-navigation criteria for external account provider queries.
///
/// All filter criteria are optional. Set non-nil/non-default values only for the properties you want to use for filtering.
public struct ExternalAccountProvidersQuery {
    /// The default and maximum number of results per page.
    public static let defaultLimit = 100
    /// The page index that indicates the first page of results.
    public static let firstPageNumber = 0
    
    /// Limit search results to account providers whose keyword, postal code, city, or state begins with the search string. Case-insensitive.
    public let search: String?
    /// Limit search results to account providers with the specified category.
    public let category: ExternalAccountProviderCategory?
    /// Maximum number of results per page. Default and maximum value is 100.
    public let limit: Int
    /// Identifies a specific page of data to fetch. The default is `firstPageNumber`, fetching the first page of results. For convenience, to fetch the page following a given ``ExternalAccountProvidersResultPage``, use `page(after:)` to construct a copy of this query with `pageNumber` incremented.
    public let pageNumber: Int
    
    /// Initializes a new query for a page of external account providers with various filters.
    /// - Parameters:
    ///   - search: Limit search results to account providers whose keyword, postal code, city, or state begins with the search string. Case-insensitive.
    ///   - category: Limit search results to account providers with the specified category.
    ///   - limit: Limit search results to account providers with the specified category.
    ///   - pageNumber: Identifies a specific page of data to fetch. The default is `firstPageNumber`, fetching the first page of results. For convenience, to fetch the page following a given ``ExternalAccountProvidersResultPage``, use `page(after:)` to construct a copy of this query with `pageNumber` incremented.
    public init(search: String? = nil, category: ExternalAccountProviderCategory? = nil, limit: Int = defaultLimit, pageNumber: Int = firstPageNumber) {
        self.search = search
        self.category = category
        self.limit = max(1, min(limit, Self.defaultLimit))
        self.pageNumber = max(Self.firstPageNumber, pageNumber)
    }
    
    /// Creates a copy of this query for a page of results following the given page, with the same filters as the original query.
    /// - Parameter page: the previous page of results, which should have been produced with this query.
    /// - Returns: A copy of this query, with `pageNumber` set to fetch results following the given `page`, if there are additional results to fetch. If there are no additional results available, returns `nil`. The query returned, if any, has the same filters as the original.
    public func page(after page: ExternalAccountProvidersResultPage) -> ExternalAccountProvidersQuery? {
        let nextPageNumber = page.pageNumber + 1
        guard limit > 0, (nextPageNumber * limit) < page.totalCount else {
            return nil
        }
        return ExternalAccountProvidersQuery(search: self.search, category: self.category, limit: self.limit, pageNumber: nextPageNumber)
    }
}

/// A page of external account providers.
///
/// Call `page(after:)` on the original `ExternalAccountProvidersQuery` that produced these results to construct a query that will fetch the next page.
public struct ExternalAccountProvidersResultPage {
    public struct APIResponse: Decodable {
        public let externalAccountProviders: [ExternalAccountProvider]
        public let totalExternalAccountProviders: Int
    }
    
    /// A list of providers filtered by the query criteria.
    public let externalAccountProviders: [ExternalAccountProvider]
    /// The total number of providers across all pages of results matching the query criteria.
    public let totalCount: Int
    /// The page index for this specific page of results.
    public let pageNumber: Int
    
    /// `APIResponse`—the data returned from the API endpoint—does not include a `pageNumber`. Combine the APIResponse with the query that produced the response so the caller has access to the `pageNumber` to safely perform paging.
    public init(result: APIResponse, query: ExternalAccountProvidersQuery) {
        self.externalAccountProviders = result.externalAccountProviders
        self.totalCount = result.totalExternalAccountProviders
        self.pageNumber = query.pageNumber
    }
}

/// The type of external account provider.
public struct ExternalAccountProviderCategory: RawRepresentable, Equatable, Hashable, Codable {
    public typealias RawValue = String
    
    /// A generic provider type.
    public static let provider = ExternalAccountProviderCategory(rawValue: "Provider")
    /// A provider that represents a health plan.
    public static let healthPlan = ExternalAccountProviderCategory(rawValue: "Health Plan")
    /// A provider that represents a device manufacturer.
    public static let deviceManufacturer = ExternalAccountProviderCategory(rawValue: "Device Manufacturer")
    
    /// The raw value for the provider category as stored in MyDataHelps.
    public let rawValue: String
    
    /// Initializes an `ExternalAccountProviderCategory` with an arbitrary value. Consider using static members such as `ExternalAccountProviderCategory.provider` instead for known values.
    /// - Parameter rawValue: The raw value for the provider category as stored in MyDataHelps.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// An external account provider supported by MyDataHelps.
///
/// Use `ParticipantSession.connectExternalAccount` to initiate a connected account between the participant and this provider.
public struct ExternalAccountProvider: Identifiable, Decodable {
    /// Assigned identifier for an ExternalAccountProvider.
    public typealias ID = ScopedIdentifier<ExternalAccountProvider, Int>
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case category = "category"
        case logoURL = "logoUrl"
    }
    
    /// Assigned identifier for this external account provider.
    public let id: ID
    /// Name of the external account provider.
    public let name: String
    /// Type of account provider.
    public let category: ExternalAccountProviderCategory
    /// Full URL from which the logo can be retrieved, if one is available for the provider.
    ///
    /// This URL returns image data, e.g. `image/png`, suitable for decoding directly into a `UIImage` object and presenting in image views. It is a public URL with no authentication required. Image dimensions may vary, so it is recommended to display these images with aspect-fit scaling.
    public let logoURL: URL?
}

/// Information for presenting a provider connection authorization UI to the participant.
///
/// For detailed usage info, see documentation for `ParticipantSession.connectExternalAccount`.
public struct ExternalAccountAuthorization {
    /// The ID of the provider to connect.
    public let providerID: ExternalAccountProvider.ID
    /// To begin the provider connection flow, your app must present an `SFSafariViewController` configured with this URL so that the participant can authorize the connection with the provider.
    ///
    /// This is a unique URL specific to the participant; it provides a temporary authenticated session for use in the browser.
    public let authorizationURL: URL
    /// The URL specified in `ParticipantSession.connectExternalAccount` to indicate completion of the provider connection flow. When your app receives an incoming URL (via Universal Links or a custom scheme) that matches `finalRedirectURL`, the provider connection is complete and you can dismiss the `SFSafariViewController`.
    public let finalRedirectURL: URL
}
