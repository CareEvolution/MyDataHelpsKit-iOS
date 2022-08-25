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
    ///   - completion: Called when the request is complete, with a ``ExternalAccountProvidersResultPage`` instance on success or an error on failure. Results are ordered by name.
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery, completion: @escaping (Result<ExternalAccountProvidersResultPage, MyDataHelpsError>) -> Void) {
        load(resource: ExternalAccountProvidersQueryResource(query: query)) {
            (result: Result<ExternalAccountProvidersResultPage.APIResponse, MyDataHelpsError>) in
            completion(result.map {
                ExternalAccountProvidersResultPage(result: $0, query: query)
            })
        }
    }
        
    /// Initiates a new connected external account. Grants access to a secure OAuth connection to the specified external account provider, where the participant can provide their provider credentials and authorize MyDataHelps to retrieve data from the account.
    ///
    /// Upon receiving the completion callback, you must present an `SFSafariViewController` to the user using the secure URL in the callback's result object to complete the provider authorization flow.
    ///
    /// Upon completion of the connection flow in the Safari view, the participant is sent to the `finalRedirectURL` to indicate that the browser can be dismissed. Your app should intercept this URL via the AppDelegate's `application(_:open:options:)` or `application(_:continue:restorationHandler:)` or the SwiftUI `onOpenURL` modifier, and programmatically dismiss the SFSafariViewController when the URL is opened. Your app can use a specific path in this URL in order to differentiate it from other URLs your app may support.
    ///
    /// The user should also be allowed to manually dismiss the Safari view at any time to cancel the authorization or escape if there is an error. In these cases the finalRedirectURL will not be invoked, but you can use `SFSafariViewControllerDelegate` to be notified of manual dismissal if needed.
    ///
    /// There are two options for configuring`finalRedirectURL`:
    /// - [Universal Link](https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html), e.g. `https://my.app/linkprovidercompletion`. The Universal Link domain and path must be fully configured in your app's entitlements file, the apple-app-site-association file hosted at the `my.app` domain, etc.
    /// - [Custom scheme](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app), e.g. `myapp://linkprovidercompletion`. Your app's Info.plist file must register the scheme `myapp` in the URL Types list.
    ///
    /// Contact [CareEvolution support](https://developer.mydatahelps.org/help.html) to have your `finalRedirectURL` added to the list of allowed URLs in MyDataHelps. If the URL is not in the allow list, this API will produce an error result.
    /// - Parameters:
    ///   - provider: The external account provider to connect.
    ///   - finalRedirectURL: A URL that is configured to open your app via a custom scheme or Universal Link.
    ///   - completion: Called when the request is complete, with the provider authorization URL and supporting information on success, or an error on failure.
    func connectExternalAccount(provider: ExternalAccountProvider, finalRedirectURL: URL, completion: @escaping (Result<ExternalAccountAuthorization, MyDataHelpsError>) -> Void) {
        load(resource: ConnectExternalAccountResource(providerID: provider.id, finalRedirectURL: finalRedirectURL)) {
            completion($0.map {
                ExternalAccountAuthorization(provider: provider, authorizationURL: $0, finalRedirectURL: finalRedirectURL)
            })
        }
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
        guard page.externalAccountProviders.count >= limit else {
            return nil
        }
        return ExternalAccountProvidersQuery(search: self.search, category: self.category, limit: self.limit, pageNumber: page.pageNumber + 1)
    }
}

/// A page of external account providers.
///
/// Call `page(after:)` on the original `ExternalAccountProvidersQuery` that produced these results to construct a query that will fetch the next page.
public struct ExternalAccountProvidersResultPage {
    internal struct APIResponse: Decodable {
        let externalAccountProviders: [ExternalAccountProvider]
        let totalExternalAccountProviders: Int
    }
    
    /// A list of providers filtered by the query criteria.
    public let externalAccountProviders: [ExternalAccountProvider]
    /// The total number of providers across all pages of results matching the query criteria.
    public let totalCount: Int
    /// The page index for this specific page of results.
    public let pageNumber: Int
    
    /// `APIResponse`—the data returned from the API endpoint—does not include a `pageNumber`. Combine the APIResponse with the query that produced the response so the caller has access to the `pageNumber` to safely perform paging.
    internal init(result: APIResponse, query: ExternalAccountProvidersQuery) {
        self.externalAccountProviders = result.externalAccountProviders
        self.totalCount = result.totalExternalAccountProviders
        self.pageNumber = query.pageNumber
    }
}

/// The type of external account provider.
public struct ExternalAccountProviderCategory: RawRepresentable, Equatable, Hashable, Decodable {
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
    /// The provider to connect.
    public let provider: ExternalAccountProvider
    /// To begin the provider connection flow, your app must present an `SFSafariViewController` configured with this URL so that the participant can authorize the connection with the provider.
    ///
    /// This is a unique URL specific to the participant; it provides a temporary authenticated session for use in the browser.
    public let authorizationURL: URL
    /// The URL specified in `ParticipantSession.connectExternalAccount` to indicate completion of the provider connection flow. When your app receives an incoming URL (via Universal Links or a custom scheme) that matches `finalRedirectURL`, the provider connection is complete and you can dismiss the `SFSafariViewController`.
    public let finalRedirectURL: URL
}

