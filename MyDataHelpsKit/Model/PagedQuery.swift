//
//  PagedQuery.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/26/21.
//

import Foundation

/// API operations that expect pages of results conform to this protocol.
internal protocol PagedQuery {
    /// The model type of the result object.
    associatedtype ResultType: PagedResult
    /// Identifies a specific page of data to fetch. Use `nil` to fetch the first page of results.
    var pageID: ScopedIdentifier<ResultType, String>? { get }
    /// Should initialize a new request for a page of results following the given page, with the same filters as the original query.
    func page(after page: ResultType) -> Self?
}

/// API response model that represents a paged collection of results.
internal protocol PagedResult {
    /// The `pageID` to use to fetch the next page of results.
    var nextPageID: ScopedIdentifier<Self, String>? { get }
}

internal extension PagedQuery {
    /// Restricts a PagedQuery's maximum number of results per page to a valid range
    /// - Parameters:
    ///   - value: The input to validate
    ///   - maxLimit: Maximum allowed value
    /// - Returns: A valid limit value >= 1
    static func clampedLimit(_ value: Int, max maxLimit: Int) -> Int {
        max(1, min(value, maxLimit))
    }
}
