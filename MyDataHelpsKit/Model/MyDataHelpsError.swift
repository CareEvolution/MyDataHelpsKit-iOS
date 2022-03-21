//
//  MyDataHelpsError.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

/// Detailed categorization of errors produced by MyDataHelpsKit.
///
/// Do not expect error descriptions to be user-readable or localized,
/// unless otherwise specified.
public enum MyDataHelpsError: Error {
    /// Failure to decode a model object.
    case decodingError(Error)
    /// Failure to encode a model object.
    case encodingError(Error)
    /// Unexpected server error, e.g. an HTTP 500 error. Check the included `HTTPResponseError` for details, and [contact support](https://developer.rkstudio.careevolution.com/help.html) if you need help determining the problem.
    case serverError(HTTPResponseError)
    /// Server request limit exceeded. The associated `APIRateLimit` indicates when throttling will reset, and the `HTTPResponseError` may include an error message (non-localized) suitable for debugging. [Contact support](https://developer.rkstudio.careevolution.com/help.html) with any questions.
    case tooManyRequests(APIRateLimit, HTTPResponseError)
    /// A server request timed out.
    case timedOut(Error)
    /// A server request had a missing or invalid access token. The access token should be refreshed and a new `ParticipantSession` created, if applicable.
    case unauthorizedRequest(HTTPResponseError)
    /// Web content (e.g. an embeddable survey) unexpectedly failed to load, due to a network, server, or web content failure. Includes any underlying error, if available.
    case webContentError(Error?)
    /// A wrapper for unexpected errors. Includes the underlying Error object that triggered the unexpected error, if applicable.
    case unknown(Error?)
}

/// Details about a failed HTTP request or an HTTP response that indicated an error.
public struct HTTPResponseError: Error {
    /// HTTP status code, e.g. 500.
    public let statusCode: Int
    /// Error message encoded in the response body, if successfully parsed.
    public let message: String?
    
    internal init(response: HTTPURLResponse, data: Data?, error: Error?) {
        self.statusCode = response.statusCode
        switch (response.mimeType ?? "", data) {
        case ("text/plain", .some(let data)):
            self.message = String(data: data, encoding: .utf8)
        case ("application/json", .some(let data)):
            if let dict = try? JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary,
               let message = dict["message"] as? String {
                self.message = message
            } else {
                self.message = String(jsonStringFragment: data)
            }
        default:
            self.message = error?.localizedDescription
        }
    }
}

fileprivate extension String {
    init?(jsonStringFragment data: Data) {
        if let value = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? String {
            self = value
        } else {
            return nil
        }
    }
}

internal extension DecodingError {
    static var emptyHTTPResponse: DecodingError {
        .dataCorrupted(.init(codingPath: [], debugDescription: "Unexpected empty HTTP response"))
    }
}
