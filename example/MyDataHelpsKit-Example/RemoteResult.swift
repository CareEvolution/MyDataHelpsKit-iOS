//
//  RemoteResult.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/30/23.
//

import Foundation
import MyDataHelpsKit

enum RemoteResult<Success> {
    case loading
    case success(Success)
    case failure(MyDataHelpsError)
    
    var value: Success? {
        switch self {
        case let .success(result):
            return result
        default:
            return nil
        }
    }
}

extension RemoteResult {
    init(wrapping block: @autoclosure () async throws -> Success) async {
        do {
            self = .success(try await block())
        } catch {
            self = .failure(MyDataHelpsError(error))
        }
    }
}
