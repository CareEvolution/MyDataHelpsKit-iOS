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
