//
//  APIRateLimit.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/2/22.
//

import Foundation

/// Information about MyDataHelps API request limits (throttling).
///
/// MyDataHelps API endpoints may limit the number of requests per hour, counting the cumulative number of requests in hourly intervals per project or similar scope, and resetting the counter at the end of each interval. If the limit is exceeded, requests will fail until the next scheduled reset time. Failures due to rate limiting are indicated by the `MyDataHelpsError.tooManyRequests` error case.
///
/// The properties of APIRateLimit should be considered approximate and may have changed before your app reads them, for example due to other clients making concurrent requests.
public struct APIRateLimit {
    /// Maximum number of requests allowed per hour for this client or MyDataHelps project.
    public let maxRequestsPerHour: Int
    /// Approximate number of API requests remaining until the limit is exceeded.
    public let remainingRequests: Int
    /// Indicates the approximate time the request limit counter will be reset. If your API interactions are failing with the `tooManyRequests` error, they should work again if you retry after the `nextReset` date.
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
