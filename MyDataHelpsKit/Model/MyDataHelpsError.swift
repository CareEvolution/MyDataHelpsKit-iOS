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
    /// Survey failed to present to the user because of an invalid survey name.
    case invalidSurvey
    /// Unexpected server error, e.g. an HTTP 500 error. Check the included `HTTPResponseError` for details, and [contact support](https://developer.mydatahelps.org/help.html) if you need help determining the problem.
    case serverError(HTTPResponseError)
    /// Server request limit exceeded. The associated `APIRateLimit` indicates when throttling will reset, and the `HTTPResponseError` may include an error message (non-localized) suitable for debugging. [Contact support](https://developer.mydatahelps.org/help.html) with any questions.
    case tooManyRequests(APIRateLimit, HTTPResponseError)
    /// A server request timed out.
    case timedOut(Error?)
    /// A server request had a missing or invalid access token. The access token should be refreshed and a new `ParticipantSession` created, if applicable.
    case unauthorizedRequest(HTTPResponseError)
    /// Web content (e.g. a MyDataHelps survey) unexpectedly failed to load, due to a network, server, or web content failure. Includes any underlying error, if available.
    case webContentError(Error?)
    /// A wrapper for unexpected errors. Includes the underlying Error object that triggered the unexpected error, if applicable.
    case unknown(Error?)
}

public extension MyDataHelpsError {
    /// Converts any `Error` to a `MyDataHelpsError`.
    ///
    /// Throwing functions in MyDataHelpsKit are designed to always throw a `MyDataHelpsError`. This is a convenience method to safely cast errors thrown by MyDataHelpsKit into the original `MyDataHelpsError`.
    ///
    /// Example:
    ///
    ///     do {
    ///         print(try await session.getParticipantInfo())
    ///     }
    ///     catch {
    ///         // getParticipantInfo should throw a MyDataHelpsError.
    ///         // This safely casts the thrown error to a MyDataHelpsError
    ///         // without an extra 'catch let...as...' block.
    ///         print(MyDataHelpsError(error))
    ///     }
    /// - Parameter error: Any `Error` object. If it is a `MyDataHelpsError`, this initializer produces an identical `MyDataHelpsError`. If not, produces `.unknown(error)`.
    init(_ error: Error) {
        if let myDataHelpsError = error as? MyDataHelpsError {
            self = myDataHelpsError
        } else {
            self = .unknown(error)
        }
    }
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
