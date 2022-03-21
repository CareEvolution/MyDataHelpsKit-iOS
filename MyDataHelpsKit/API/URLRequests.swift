//
//  URLRequests.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

enum RequestMethod: String {
    case GET
    case POST
    case DELETE
}

extension ISO8601DateFormatter {
    static let myDataHelpsFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withTimeZone, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFractionalSeconds]
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()
    
    static let myDataHelpsFormatterNoFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withTimeZone, .withDashSeparatorInDate, .withColonSeparatorInTime]
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()
}

extension Date {
    var queryStringEncoded: String {
        ISO8601DateFormatter.myDataHelpsFormatter.string(from: self)
    }
}

extension JSONEncoder {
    static let myDataHelpsEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom({ date, encoder in
            let string = ISO8601DateFormatter.myDataHelpsFormatter.string(from: date)
            var container = encoder.singleValueContainer()
            try container.encode(string)
        })
        return encoder
    }()
}

extension JSONDecoder {
    public static let myDataHelpsDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Two separate date formatters needed to support ISO 8601 with and without fractional seconds
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = ISO8601DateFormatter.myDataHelpsFormatter.date(from: string)
                    ?? ISO8601DateFormatter.myDataHelpsFormatterNoFractionalSeconds.date(from: string) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO 8601 date string: \(string)")
            }
            return date
        })
        
        return decoder
    }()
}

extension MyDataHelpsClient {
    func endpoint(path: String) -> URL {
        baseURL.appendingPathComponent(path)
    }
    
    func endpoint(path: String, queryItems: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw MyDataHelpsError.unknown(nil)
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw MyDataHelpsError.unknown(nil)
        }
        return url
    }
}

extension ParticipantSession {
    func authenticatedRequest(_ method: RequestMethod, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(accessToken.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(client.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(client.languageTag, forHTTPHeaderField: "Accept-Language")
        return request
    }
}

extension URLRequest {
    mutating func setJSONBody<T: Encodable>(_ model: T) throws {
        httpBody = try JSONEncoder.myDataHelpsEncoder.encode(model)
        setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}

extension HTTPURLResponse {
    /// Shim for `value(forHTTPHeaderField:)` which is iOS 13-only.
    func headerValue(field: String) -> String? {
        if #available(iOS 13.0, *) {
            return value(forHTTPHeaderField: field)
        } else {
            // Cast to NSDictionary so key lookup is case-insensitive
            return (allHeaderFields as NSDictionary)[field] as? String
        }
    }
}

extension Collection where Element == String {
    var commaDelimitedQueryValue: String? {
        guard !isEmpty else { return nil }
        return map { $0.replacingOccurrences(of: ",", with: "\\,") }
            .joined(separator: ",")
    }
}
