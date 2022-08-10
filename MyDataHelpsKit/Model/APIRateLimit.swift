//
//  APIRateLimit.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/2/22.
//

import Foundation

/// Information about MyDataHelps API request limits (throttling). The MyDataHelps API has a rate limiting feature to preserve stability for all customers. Failures due to rate limiting are indicated by the `MyDataHelpsError.tooManyRequests` error case.
///
/// The properties of APIRateLimit help you understand your rate limits and usage, which may vary based on project licensing and scope. See [Rate Limits documentation](https://developer.mydatahelps.org/api/limits.html) for additional information.
public struct APIRateLimit {
    /// Number of requests allowed per hour (total) for this scope.
    public let maxRequestsPerHour: Int
    /// Number of requests remaining this hour for this scope.
    public let remainingRequests: Int
    /// When the rate limit will be reset. If your API interactions are failing with the `tooManyRequests` error, they should work again if you retry after the `nextReset` date.
    public let nextReset: Date
    
    init?(response: HTTPURLResponse) {
        guard let limit = response.headerValue(field: "RateLimit-Limit").flatMap({ Int($0) }),
              let remaining = response.headerValue(field: "RateLimit-Remaining").flatMap({ Int($0) }),
              let reset = response.headerValue(field: "RateLimit-Reset").flatMap({ Int($0) }) else {
                  return nil
              }
        
        self.maxRequestsPerHour = limit
        self.remainingRequests = remaining
        self.nextReset = Date(timeIntervalSinceNow: TimeInterval(reset))
    }
}
