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
    func getParticipantInfo() async throws -> ParticipantInfo
    func getProjectInfo() async throws -> ProjectInfo
    func getDataCollectionSettings() async throws -> ProjectDataCollectionSettings
    func queryDeviceData(_ query: DeviceDataQuery) async throws -> DeviceDataResultPage
    func querySurveyTasks(_ query: SurveyTaskQuery) async throws -> SurveyTaskResultPage
    func querySurveyAnswers(_ query: SurveyAnswersQuery) async throws -> SurveyAnswersPage
    func deleteSurveyResult(_ surveyResultID: SurveyResult.ID) async throws
    func queryNotifications(_ query: NotificationHistoryQuery) async throws -> NotificationHistoryPage
    func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel]) async throws
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery) async throws -> ExternalAccountProvidersResultPage
    func connectExternalAccount(provider: ExternalAccountProvider, finalRedirectURL: URL) async throws -> ExternalAccountAuthorization
    func listExternalAccounts() async throws -> [ExternalAccount]
    func refreshExternalAccount(_ account: ExternalAccount) async throws
    func deleteExternalAccount(_ account: ExternalAccount) async throws
}

extension ParticipantSession: ParticipantSessionType {
}

#if DEBUG

/// Stub implementation of ParticipantSession/ParticipantSessionType, for SwiftUI previews.
class ParticipantSessionPreview: ParticipantSessionType {
    private let empty: Bool
    
    struct NotImplementedForSwiftUIPreviews: Error { }
    
    init(empty: Bool = false) {
        self.empty = empty
    }
    
    func getParticipantInfo() async throws -> ParticipantInfo {
        return try await delayedSuccess(data: PreviewData.participantInfoJSON)
    }
    
    func getProjectInfo() async throws -> ProjectInfo {
        return await ProjectInfoView_Previews.project
    }
    
    func getDataCollectionSettings() async throws -> ProjectDataCollectionSettings {
        return await ProjectInfoView_Previews.projectDataCollectionSettings
    }
    
    func queryDeviceData(_ query: DeviceDataQuery) async throws -> DeviceDataResultPage {
        throw NotImplementedForSwiftUIPreviews()
    }
    
    func querySurveyTasks(_ query: SurveyTaskQuery) async throws -> SurveyTaskResultPage {
        if empty || query.pageID != nil {
            return try await delayedSuccess(data: PreviewData.emptyPage(modelKey: "surveyTasks"))
        } else {
            return try await delayedSuccess(data: PreviewData.surveyTasksPageJSON)
        }
    }
    
    func querySurveyAnswers(_ query: SurveyAnswersQuery) async throws -> SurveyAnswersPage {
        if empty || query.pageID != nil {
            return try await delayedSuccess(data: PreviewData.emptyPage(modelKey: "surveyAnswers"))
        } else {
            return try await delayedSuccess(data: PreviewData.surveyAnswersPageJSON)
        }
    }
    
    func deleteSurveyResult(_ surveyResultID: SurveyResult.ID) async throws {
    }
    
    func queryNotifications(_ query: NotificationHistoryQuery) async throws -> NotificationHistoryPage {
        if empty {
            return try await delayedSuccess(data: PreviewData.emptyPage(modelKey: "notifications"))
        } else {
            return try await delayedSuccess(data: PreviewData.notificationHistoryPageJSON)
        }
    }
    
    func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel]) async throws {
    }
    
    func queryExternalAccountProviders(_ query: ExternalAccountProvidersQuery) async throws -> ExternalAccountProvidersResultPage {
        throw NotImplementedForSwiftUIPreviews()
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
        let model = try JSONDecoder.myDataHelpsDecoder.decode(T.self, from: data)
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
    
    static func emptyPage(modelKey: String) -> Data {
        """
        {
          "\(modelKey)": [ ],
          "nextPageID": null
        }
        """.data(using: .utf8)!
    }
    
    static let participantInfoJSON = """
    {
      "participantID": "\(UUID().uuidString)",
      "participantIdentifier": "\(UUID().uuidString)",
      "secondaryIdentifier": "secondary-1",
      "demographics": {
        "email": "email@example.com",
        "mobilePhone": "(555) 555-1212",
        "firstName": "FName",
        "middleName": "M",
        "lastName": "LName",
        "street1": "123 Street St",
        "street2": "Apt #1",
        "city": "Anywhere",
        "state": "MI",
        "postalCode": "55555",
        "dateOfBirth": "1999-12-31",
        "preferredLanguage": "en",
        "gender": "O",
        "utcOffset": "-04:00:00",
        "unsubscribedFromEmails": "true",
        "unsubscribedFromSms": "false",
        "timeZone": "America/New_York"
      },
      "customFields": {
        "MOBILE_PHONE": "(555) 555-1212",
      },
      "enrollmentDate": "2020-05-12T16:50:55.528+00:00",
      "projectID": "\(UUID().uuidString)"
    }
    """.data(using: .utf8)!
    
    static let provider1JSONText = """
        { "id": 1, "name": "MyDataHelps Demo Provider", "category": "Provider", "logoUrl": "https://developer.mydatahelps.org/assets/images/mydatahelps-logo.png" }
    """
    
    static let providersJSON = """
    {
        "externalAccountProviders": [ \(provider1JSONText) ],
        "totalExternalAccountProviders": 1
    }
    """.data(using: .utf8)!
    
    static let accountsJSON = """
    [
        { "id": 100, "status": "fetchComplete", "provider": \(provider1JSONText), "lastRefreshDate": "2021-08-01T12:34:56.000Z" }
    ]
    """.data(using: .utf8)!
    
    static var surveyTasksPageJSON: Data { """
{
  "surveyTasks": [
    {
      "id": "\(SurveyTask.ID(UUID().uuidString))",
      "surveyID": "\(Survey.ID(UUID().uuidString))",
      "surveyName": "SurveyName1",
      "surveyDisplayName": "Survey Display Name 1",
      "surveyDescription": "Description 1",
      "startDate": null,
      "endDate": null,
      "status": "incomplete",
      "hasSavedProgress": false,
      "dueDate": "2023-03-28T20:42:07.572+00:00",
      "insertedDate": "2023-03-14T20:42:07.583Z",
      "modifiedDate": "2023-03-14T20:42:07.583Z"
    },
    {
      "id": "\(SurveyTask.ID(UUID().uuidString))",
      "surveyID": "\(Survey.ID(UUID().uuidString))",
      "surveyName": "SurveyName1",
      "surveyDisplayName": "Survey Display Name 1",
      "surveyDescription": "Description 1",
      "startDate": "2023-03-14T16:38:00-04:00",
      "endDate": "2023-03-14T16:38:36-04:00",
      "status": "complete",
      "hasSavedProgress": false,
      "dueDate": "2023-03-28T20:35:49.288+00:00",
      "insertedDate": "2023-03-14T20:35:49.293Z",
      "modifiedDate": "2023-03-14T20:38:37.163Z"
    },
    {
      "id": "\(SurveyTask.ID(UUID().uuidString))",
      "surveyID": "\(Survey.ID(UUID().uuidString))",
      "surveyName": "SurveyName2",
      "surveyDisplayName": "Survey Display Name 2",
      "surveyDescription": "",
      "status": "incomplete",
      "hasSavedProgress": true,
      "dueDate": null,
      "insertedDate": "2023-03-07T20:44:45.613Z",
      "modifiedDate": "2023-03-15T13:52:26.68Z"
    }
  ],
  "nextPageID": "\(SurveyTaskResultPage.PageID(UUID().uuidString))"
}
""".data(using: .utf8)! }
    
    static var surveyAnswersPageJSON: Data { """
{
  "surveyAnswers": [
    {
      "id": "\(SurveyAnswer.ID(UUID().uuidString))",
      "surveyResultID": "\(SurveyResult.ID(UUID().uuidString))",
      "surveyID": "\(Survey.ID(UUID().uuidString))",
      "surveyVersion": 0,
      "taskID": "\(SurveyTask.ID(UUID().uuidString))",
      "surveyName": "SurveyName1",
      "surveyDisplayName": "Survey Display Name 1",
      "date": "2023-03-15T10:26:11.428-04:00",
      "stepIdentifier": "Step 1",
      "resultIdentifier": "Step 1",
      "answers": [
        "3.21"
      ],
      "insertedDate": "2023-03-15T14:26:13.753Z"
    },
    {
      "id": "\(SurveyAnswer.ID(UUID().uuidString))",
      "surveyResultID": "\(SurveyResult.ID(UUID().uuidString))",
      "surveyID": "\(Survey.ID(UUID().uuidString))",
      "surveyVersion": 19,
      "taskID": null,
      "surveyName": "SurveyName2",
      "surveyDisplayName": "Survey Display Name 2",
      "date": "2023-03-15T10:24:53.775-04:00",
      "stepIdentifier": "FormStep1",
      "resultIdentifier": "FormStep1Item1",
      "answers": [
        "Choice 2", "Choice 4"
      ],
      "insertedDate": "2023-03-15T14:24:53.953Z"
    },
    {
      "id": "\(SurveyAnswer.ID(UUID().uuidString))",
      "surveyResultID": "\(SurveyResult.ID(UUID().uuidString))",
      "surveyID": "\(Survey.ID(UUID().uuidString))",
      "surveyVersion": 19,
      "surveyName": "SurveyName2",
      "surveyDisplayName": "Survey Display Name 2",
      "stepIdentifier": "WebViewStep1",
      "resultIdentifier": "WebViewStep1",
      "answers": [
      ],
      "insertedDate": "2023-03-15T14:24:53.95Z"
    }
  ],
  "nextPageID": "\(SurveyAnswersPage.PageID(UUID().uuidString))"
}
""".data(using: .utf8)! }
    
    static var notificationHistoryPageJSON: Data { """
{
  "notifications": [
    {
      "id": "\(UUID().uuidString)",
      "identifier": "SMSExample1",
      "sentDate": "2022-08-10T12:31:36.547+00:00",
      "statusCode": "Succeeded",
      "type": "Sms",
      "content": {
        "body": "A sample SMS notification."
      }
    },
    {
      "id": "\(UUID().uuidString)",
      "identifier": "PushExample2",
      "sentDate": "2022-06-30T17:16:20.52+00:00",
      "statusCode": "Succeeded",
      "type": "Push",
      "content": {
        "title": "Push Title",
        "body": "A sample push notification."
      }
    },
    {
      "id": "\(UUID().uuidString)",
      "identifier": "EmailExample3",
      "sentDate": "2022-06-02T14:55:27.78+00:00",
      "statusCode": "Succeeded",
      "type": "Email",
      "content": {
        "subject": "A sample email subject line."
      }
    }
  ],
  "nextPageID": null
}
""".data(using: .utf8)! }
}

#endif
