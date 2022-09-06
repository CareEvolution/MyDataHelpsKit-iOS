//
//  FoundationExtensions.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 9/6/22.
//

import Foundation
import MyDataHelpsKit

extension Result where Failure == MyDataHelpsError {
    /// Convenience initializer to map MyDataHelpsKit async throwing functions to Result objects.
    /// - Parameter block: The async throwing function.
    init(wrapping block: @autoclosure () async throws -> Success) async {
        do {
            self = .success(try await block())
        } catch {
            self = .failure(MyDataHelpsError(error))
        }
    }
}
