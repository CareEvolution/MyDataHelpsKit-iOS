//
//  ParticipantSessionType.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 8/27/21.
//

import Foundation
import MyDataHelpsKit

/// Protocol wrapping MyDataHelpsKit.ParticipantSession, to allow substituting stub implementations for SwiftUI Previews.
protocol ParticipantSessionType {
    func getParticipantInfoViewModel() async throws -> ParticipantInfoViewModel
    func queryDeviceData(_ query: DeviceDataQuery) async throws -> DeviceDataResultPage
    func querySurveyTasks(_ query: SurveyTaskQuery) async throws -> SurveyTaskResultPage
    func querySurveyAnswers(_ query: SurveyAnswersQuery) async throws -> SurveyAnswersPage
    func deleteSurveyResult(_ surveyResultID: SurveyResult.ID) async throws
    func queryNotifications(_ query: NotificationHistoryQuery) async throws -> NotificationHistoryPage
    func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel]) async throws
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery) async throws -> [ExternalAccountProvider]
    func connectExternalAccount(provider: ExternalAccountProvider, finalRedirectURL: URL) async throws -> ExternalAccountAuthorization
    func listExternalAccounts() async throws -> [ExternalAccount]
    func refreshExternalAccount(_ account: ExternalAccount) async throws
    func deleteExternalAccount(_ account: ExternalAccount) async throws
}

extension ParticipantSession: ParticipantSessionType {
    func getParticipantInfoViewModel() async throws -> ParticipantInfoViewModel {
        return .init(info: try await getParticipantInfo())
    }
}

#if DEBUG

/// Stub implementation of ParticipantSession/ParticipantSessionType, for SwiftUI previews.
class ParticipantSessionPreview: ParticipantSessionType {
    private let empty: Bool
    
    struct NotImplementedForSwiftUIPreviews: Error { }
    
    init(empty: Bool = false) {
        self.empty = empty
    }
    
    func getParticipantInfoViewModel() async throws -> ParticipantInfoViewModel {
        return .init(name: "name", linkIdentifier: nil, email: "email", phone: "phone", enrollmentDate: Date(), isUnsubscribedFromEmails: false)
    }
    
    public func queryDeviceData(_ query: DeviceDataQuery) async throws -> DeviceDataResultPage {
        throw NotImplementedForSwiftUIPreviews()
    }
    
    func querySurveyTasks(_ query: SurveyTaskQuery) async throws -> SurveyTaskResultPage {
        throw NotImplementedForSwiftUIPreviews()
    }
    
    func querySurveyAnswers(_ query: SurveyAnswersQuery) async throws -> SurveyAnswersPage {
        throw NotImplementedForSwiftUIPreviews()
    }
    
    func deleteSurveyResult(_ surveyResultID: SurveyResult.ID) async throws {
    }
    
    func queryNotifications(_ query: NotificationHistoryQuery) async throws -> NotificationHistoryPage {
        throw NotImplementedForSwiftUIPreviews()
    }
    
    func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel]) async throws {
    }
    
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery) async throws -> [ExternalAccountProvider] {
        return try await delayedSuccess(data: PreviewData.providersJSON)
    }
    
    func connectExternalAccount(provider: ExternalAccountProvider, finalRedirectURL: URL) async throws -> ExternalAccountAuthorization {
        throw NotImplementedForSwiftUIPreviews()
    }
    
    func listExternalAccounts() async throws -> [ExternalAccount] {
        if empty {
            return try await delayedSuccess(data: PreviewData.emptyArray)
        } else {
            return try await delayedSuccess(data: PreviewData.accountsJSON)
        }
    }
    
    func refreshExternalAccount(_ account: ExternalAccount) async throws {
    }
    
    func deleteExternalAccount(_ account: ExternalAccount) async throws {
    }
    
    private func delayedSuccess<T: Decodable>(data: Data) async throws -> T {
        guard let model = try? JSONDecoder.myDataHelpsDecoder.decode(T.self, from: data) else {
            throw MyDataHelpsError.decodingError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "")))
        }
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                continuation.resume(with: .success(model))
            }
        }
    }
}

extension ExternalAccount {
    static var previewList: [ExternalAccount] {
        try! JSONDecoder.myDataHelpsDecoder.decode([ExternalAccount].self, from: PreviewData.accountsJSON)
    }
}

/// Namespace for sample/preview data objects, mainly representing API response JSON decodable into MyDataHelpsKit model types.
enum PreviewData {
    static let emptyArray = "[]".data(using: .utf8)!
    
    static let provider1JSONText = """
        { "id": 1, "name": "MyDataHelps Demo Provider", "category": "Provider", "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png" }
    """
    
    static let providersJSON = """
    [
        \(provider1JSONText)
    ]
    """.data(using: .utf8)!
    
    static let accountsJSON = """
    [
        { "id": 100, "status": "fetchComplete", "provider": \(provider1JSONText), "lastRefreshDate": "2021-08-01T12:34:56.000Z" }
    ]
    """.data(using: .utf8)!
}

#endif
