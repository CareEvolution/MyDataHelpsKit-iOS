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
    func getParticipantInfoViewModel(completion: @escaping (Result<ParticipantInfoViewModel, MyDataHelpsError>) -> Void)
    func queryDeviceData(_ query: DeviceDataQuery, completion: @escaping (Result<DeviceDataResultPage, MyDataHelpsError>) -> Void)
    func querySurveyTasks(_ query: SurveyTaskQuery, completion: @escaping (Result<SurveyTaskResultPage, MyDataHelpsError>) -> Void)
    func querySurveyAnswers(_ query: SurveyAnswersQuery, completion: @escaping (Result<SurveyAnswersPage, MyDataHelpsError>) -> Void)
    func deleteSurveyResult(_ surveyResultID: SurveyResult.ID, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void)
    func queryNotifications(_ query: NotificationHistoryQuery, completion: @escaping (Result<NotificationHistoryPage, MyDataHelpsError>) -> Void)
    func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel], completion: @escaping (Result<Void, MyDataHelpsError>) -> Void)
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery, completion: @escaping (Result<ExternalAccountProvidersResultPage, MyDataHelpsError>) -> Void)
    func connectExternalAccount(provider: ExternalAccountProvider, finalRedirectURL: URL, completion: @escaping (Result<ExternalAccountAuthorization, MyDataHelpsError>) -> Void)
    func listExternalAccounts(completion: @escaping (Result<[ExternalAccount], MyDataHelpsError>) -> Void)
    func refreshExternalAccount(_ account: ExternalAccount, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void)
    func deleteExternalAccount(_ account: ExternalAccount, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void)
}

extension ParticipantSession: ParticipantSessionType {
    func getParticipantInfoViewModel(completion: @escaping (Result<ParticipantInfoViewModel, MyDataHelpsError>) -> Void) {
        getParticipantInfo { result in
            completion(result.map { .init(info: $0) })
        }
    }
}

#if DEBUG

/// Stub implementation of ParticipantSession/ParticipantSessionType, for SwiftUI previews.
class ParticipantSessionPreview: ParticipantSessionType {
    private let empty: Bool
    
    init(empty: Bool = false) {
        self.empty = empty
    }
    
    func getParticipantInfoViewModel(completion: @escaping (Result<ParticipantInfoViewModel, MyDataHelpsError>) -> Void) {
        completion(.success(.init(name: "name", linkIdentifier: nil, email: "email", phone: "phone", enrollmentDate: Date(), isUnsubscribedFromEmails: false)))
    }
    
    func queryDeviceData(_ query: DeviceDataQuery, completion: @escaping (Result<DeviceDataResultPage, MyDataHelpsError>) -> Void) {
    }
    
    func querySurveyTasks(_ query: SurveyTaskQuery, completion: @escaping (Result<SurveyTaskResultPage, MyDataHelpsError>) -> Void) {
    }
    
    func querySurveyAnswers(_ query: SurveyAnswersQuery, completion: @escaping (Result<SurveyAnswersPage, MyDataHelpsError>) -> Void) {
    }
    
    func deleteSurveyResult(_ surveyResultID: SurveyResult.ID, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void) {
        completion(.success(()))
    }
    
    func queryNotifications(_ query: NotificationHistoryQuery, completion: @escaping (Result<NotificationHistoryPage, MyDataHelpsError>) -> Void) {
    }
    
    func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel], completion: @escaping (Result<Void, MyDataHelpsError>) -> Void) {
        completion(.success(()))
    }
    
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery, completion: @escaping (Result<ExternalAccountProvidersResultPage, MyDataHelpsError>) -> Void) {
    }
    
    func connectExternalAccount(provider: ExternalAccountProvider, finalRedirectURL: URL, completion: @escaping (Result<ExternalAccountAuthorization, MyDataHelpsError>) -> Void) {
    }
    
    func listExternalAccounts(completion: @escaping (Result<[ExternalAccount], MyDataHelpsError>) -> Void) {
        if empty {
            delayedSuccess(data: PreviewData.emptyArray, completion: completion)
        } else {
            delayedSuccess(data: PreviewData.accountsJSON, completion: completion)
        }
    }
    
    func refreshExternalAccount(_ account: ExternalAccount, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void) {
        completion(.success(()))
    }
    
    func deleteExternalAccount(_ account: ExternalAccount, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void) {
        completion(.success(()))
    }
    
    private func delayedSuccess<T: Decodable>(data: Data, completion: @escaping (Result<T, MyDataHelpsError>) -> Void) {
        guard let model = try? JSONDecoder.myDataHelpsDecoder.decode(T.self, from: data) else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            completion(.success(model))
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
    {
        "externalAccountProviders": [ \(provider1JSONText) ],
        "totalExternalAccountProviders": 35
    }
    """.data(using: .utf8)!
    
    static let accountsJSON = """
    [
        { "id": 100, "status": "fetchComplete", "provider": \(provider1JSONText), "lastRefreshDate": "2021-08-01T12:34:56.000Z" }
    ]
    """.data(using: .utf8)!
}

#endif
