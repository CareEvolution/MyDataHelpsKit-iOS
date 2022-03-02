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
    func load<ResourceType: ParticipantResource>(resource: ResourceType, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void) where ResourceType.ResponseType == Void {
        do {
            let request = try resource.urlRequest(session: self)
            let task = session.dataTask(with: request) {
                let result = Self.dataResult($0, $1, $2).map { _ in () }
                completion(result)
            }
            task.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(.encodingError(error)))
            }
        }
    }
    
    func load<ResourceType: ParticipantResource>(resource: ResourceType, completion: @escaping (Result<ResourceType.ResponseType, MyDataHelpsError>) -> Void) where ResourceType.ResponseType: Decodable {
        do {
            let request = try resource.urlRequest(session: self)
            let task = session.dataTask(with: request) {
                completion(Self.responseResult($0, $1, $2))
            }
            task.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(.encodingError(error)))
            }
        }
    }
    
    static func dataResult(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Data?, MyDataHelpsError> {
        assert(Thread.isMainThread)
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
    
    static func responseResult<ResultType: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<ResultType, MyDataHelpsError> {
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
