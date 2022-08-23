//
//  ScopedIdentifier.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/12/22.
//

import Foundation

/// A unique identifier associated with a specific model type (the `Subject`) in MyDataHelps.
///
/// Most model types in this SDK have at least one identifier value, typically a string. It is an error
/// to use the identifier from a model of type A when fetching, querying, or creating models of type B.
/// ScopedIdentifiers prevent such mistakes by making it a compiler error to use a mismatched identifier.
///
/// For example, the following code mistakenly uses a `surveyID` to delete a survey result,
/// instead of the `surveyResultID`. If allowed, this would fail to delete any survey result, or possibly delete
/// the wrong survey result. ScopedIdentifiers prevents such a mistake from compiling,
/// because surveyID and surveyResultID are incompatible `ScopedIdentifier` types.
///
/// ```swift
/// func deleteSurveyResult(containing answer: SurveyAnswer) {
///     // Will not compile, and would delete the wrong survey:
///     // session.deleteSurveyResult(answer.surveyID) { ... }
///
///     // Will compile and work correctly:
///     session.deleteSurveyResult(answer.surveyResultID) { ... }
/// }
/// ```
public struct ScopedIdentifier<Subject, Value: Hashable>: Hashable {
    /// The value of the identifier.
    public let value: Value
    
    /// Initializes an identifier.
    ///
    /// Directly initializing a ScopedIdentifier is uncommon: typically, MyDataHelpsKit
    /// will fetch model objects with existing identifiers from the server (e.g. via ``ParticipantSession``),
    /// and the client will then use these existing identifiers in other API calls.
    /// - Parameter value: The value of the identifier.
    public init(_ value: Value) {
        self.value = value
    }
}

extension ScopedIdentifier: CustomStringConvertible where Value: CustomStringConvertible {
    public var description: String {
        value.description
    }
}

extension ScopedIdentifier: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        self.value = try decoder.singleValueContainer().decode(Value.self)
    }
}

extension ScopedIdentifier: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}
