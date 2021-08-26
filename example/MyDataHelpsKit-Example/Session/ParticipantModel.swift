//
//  ParticipantModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import Foundation
import MyDataHelpsKit

protocol ParticipantSessionType {
    func getParticipantInfoViewModel(completion: @escaping (Result<ParticipantInfoViewModel, MyDataHelpsError>) -> Void)
    func queryDeviceData(_ query: DeviceDataQuery, completion: @escaping (Result<DeviceDataResultPage, MyDataHelpsError>) -> Void)
    func querySurveyTasks(_ query: SurveyTaskQuery, completion: @escaping (Result<SurveyTaskResultPage, MyDataHelpsError>) -> Void)
    func querySurveyAnswers(_ query: SurveyAnswersQuery, completion: @escaping (Result<SurveyAnswersPage, MyDataHelpsError>) -> Void)
    func deleteSurveyResult(surveyResultID: String, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void)
    func queryNotifications(_ query: NotificationHistoryQuery, completion: @escaping (Result<NotificationHistoryPage, MyDataHelpsError>) -> Void)
    func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel], completion: @escaping (Result<Void, MyDataHelpsError>) -> Void)
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery, completion: @escaping (Result<[ExternalAccountProvider], MyDataHelpsError>) -> Void)
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

class ParticipantSessionPreview: ParticipantSessionType {
    private let empty: Bool
    
    init(empty: Bool = false) {
        self.empty = empty
    }
    
    func getParticipantInfoViewModel(completion: @escaping (Result<ParticipantInfoViewModel, MyDataHelpsError>) -> Void) {
        completion(.success(.init(name: "name", linkIdentifier: nil, email: "email", phone: "phone", enrollmentDate: Date())))
    }
    
    func queryDeviceData(_ query: DeviceDataQuery, completion: @escaping (Result<DeviceDataResultPage, MyDataHelpsError>) -> Void) {
    }
    
    func querySurveyTasks(_ query: SurveyTaskQuery, completion: @escaping (Result<SurveyTaskResultPage, MyDataHelpsError>) -> Void) {
    }
    
    func querySurveyAnswers(_ query: SurveyAnswersQuery, completion: @escaping (Result<SurveyAnswersPage, MyDataHelpsError>) -> Void) {
    }
    
    func deleteSurveyResult(surveyResultID: String, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void) {
        completion(.success(()))
    }
    
    func queryNotifications(_ query: NotificationHistoryQuery, completion: @escaping (Result<NotificationHistoryPage, MyDataHelpsError>) -> Void) {
    }
    
    func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel], completion: @escaping (Result<Void, MyDataHelpsError>) -> Void) {
        completion(.success(()))
    }
    
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery, completion: @escaping (Result<[ExternalAccountProvider], MyDataHelpsError>) -> Void) {
        delayedSuccess(data: PreviewData.providersJSON, completion: completion)
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

enum PreviewData {
    static let emptyArray = "[]".data(using: .utf8)!
    
    static let provider1JSONText = """
        { "id": 1, "name": "RKStudio Demo Provider", "category": "Provider", "logoUrl": "https://careevolution.com/images/rkstudio-logo.png" }
    """
    
    static let providersJSON = """
    [
        \(provider1JSONText)
    ]
    """.data(using: .utf8)!
    
    static let accountsJSON = """
    [
        { "id": 100, "status": "FetchComplete", "provider": \(provider1JSONText), "lastRefreshDate": "2021-08-01T12:34:56.000Z" }
    ]
    """.data(using: .utf8)!
}

#endif

class ParticipantModel: ObservableObject {
    let session: ParticipantSessionType
    
    @Published var info: Result<ParticipantInfoViewModel, MyDataHelpsError>? = nil
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func loadInfo() {
        if case .some(.success(_)) = info { return }
        session.getParticipantInfoViewModel { [weak self] result in
            self?.info = result
        }
    }
}
