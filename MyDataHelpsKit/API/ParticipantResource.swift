//
//  ParticipantResource.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

protocol ParticipantResource {
    associatedtype ResponseType
    func urlRequest(session: ParticipantSession) throws -> URLRequest
}

extension ParticipantSession {
    /// Performs a remote URL request with no expected response data.
    ///
    /// On success, asynchronously returns control to the caller. On failure, throws a `MyDataHelpsError`.
    /// - Parameter resource: Describes the resource to load and request to perform.
    internal func load<ResourceType: ParticipantResource>(resource: ResourceType) async throws where ResourceType.ResponseType == Void {
        let request: URLRequest
        do {
            request = try resource.urlRequest(session: self)
        } catch {
            throw MyDataHelpsError.encodingError(error)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) {
                let result = Self.dataResult($0, $1, $2).map { _ in () }
                continuation.resume(with: result)
            }
            task.resume()
        }
    }
    
    /// Performs a remote URL request and decodes the response into the specified model type.
    ///
    /// On success, asynchronously returns to the caller with the decoded model. On failure, throws a `MyDataHelpsError`.
    /// - Parameter resource: Describes the request to perform and the response model type to decode.
    /// - Returns: The decoded model.
    internal func load<ResourceType: ParticipantResource>(resource: ResourceType) async throws -> ResourceType.ResponseType where ResourceType.ResponseType: Decodable {
        let request: URLRequest
        do {
            request = try resource.urlRequest(session: self)
        } catch {
            throw MyDataHelpsError.encodingError(error)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) {
                continuation.resume(with: Self.responseResult($0, $1, $2))
            }
            task.resume()
        }
    }
    
    private static func dataResult(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Data?, MyDataHelpsError> {
        if let error = error as? URLError, error.code == URLError.Code.timedOut {
            return .failure(.timedOut(error))
        }
        guard let response = response as? HTTPURLResponse else {
            return .failure(.unknown(error))
        }
        guard response.statusCode >= 200, response.statusCode < 300 else {
            let responseError = HTTPResponseError(response: response, data: data, error: error)
            
            if response.statusCode == 429,
               let limit = APIRateLimit(response: response) {
                return .failure(.tooManyRequests(limit, responseError))
            } else if response.statusCode == 401 {
                return .failure(.unauthorizedRequest(responseError))
            } else {
                return .failure(.serverError(responseError))
            }
        }
        return .success(data)
    }
    
    private static func responseResult<ResultType: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<ResultType, MyDataHelpsError> {
        return dataResult(data, response, error).flatMap {
            guard let body = $0 else {
                return .failure(.decodingError(DecodingError.emptyHTTPResponse))
            }
            do {
                let model = try JSONDecoder.myDataHelpsDecoder.decode(ResultType.self, from: body)
                return .success(model)
            } catch {
                return .failure(.decodingError(error))
            }
        }
    }
}
