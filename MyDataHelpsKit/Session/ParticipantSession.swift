//
//  ParticipantSession.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

/// Provides a context for performing authenticated actions on behalf of the participant.
///
/// An instance of `ParticipantSession` should be retained for the lifetime of a participant's access token. Callers are responsible for tracking the state of an access token and renewing as needed.
///
/// ### Asynchronous Behavior
/// 
/// Requests to the MyDataHelps platform are typically asynchronous. All asynchronous requests in ParticipantSession are implemented with a completion parameter of type `(Result<ModelType, MyDataHelpsError>) -> Void`, where `ModelType` is the type of the data model object returned upon success. All completion blocks are invoked on the main thread.
public final class ParticipantSession {
    
    internal let client: MyDataHelpsClient
    internal let accessToken: ParticipantAccessToken
    internal let session: URLSession
    
    /// Initializes a new session using an access token.
    /// - Parameter client: The client to use for all API access by this session.
    /// - Parameter accessToken: An authentication token. Must be valid and not expired, or all actions performed with this session will fail with authorization failures.
    public init(client: MyDataHelpsClient, accessToken: ParticipantAccessToken) {
        self.client = client
        self.accessToken = accessToken
        self.session = client.newURLSession()
    }
    
    // MARK: Participant and project info
    
    /// Retrieves basic information about the participant.
    /// - Parameter completion: Called when the request is complete, with a `ParticipantInfo` instance on success or an error on failure.
    public func getParticipantInfo(completion: @escaping (Result<ParticipantInfo, MyDataHelpsError>) -> Void) {
        load(resource: GetParticipantInfoResource(), completion: completion)
    }
    
    /// Retrieves general project information.
    /// - Parameter completion: Called when the request is complete, with a ``ProjectInfo`` instance on success or an error on failure.
    public func getProjectInfo(completion: @escaping (Result<ProjectInfo, MyDataHelpsError>) -> Void) {
        load(resource: GetProjectInfoResource(), completion: completion)
    }
    
    // MARK: Device data
    
    /// Queries device data for the participant.
    ///
    /// To fetch the first page of results, call this with a new `DeviceDataQuery` object. If there are additional pages available, the next page can be fetched by using `DeviceDataQuery.page(after:)` to construct a query for the following page.
    /// - Parameters:
    ///   - query: Specifies how to filter the data, and optionally which page of data to fetch.
    ///   - completion: Called when the request is complete, with a `DeviceDataResultPage` instance on success or an error on failure. Results are ordered by most recent date.
    public func queryDeviceData(_ query: DeviceDataQuery, completion: @escaping (Result<DeviceDataResultPage, MyDataHelpsError>) -> Void) {
        load(resource: DeviceDataQueryResource(query: query), completion: completion)
    }
    
    /// Creats new and/or updates existing device data points. Each device data point is uniquely identified by a combination of its properties, called a natural key, as identified in `DeviceDataPointPersistModel`. Data points are always persisted with the `project` namespace.
    ///
    /// To update an existing device data point, persist one whose natural key properties exactly match the one to be updated. All non-natural key properties will be updated to your persisted point.
    ///
    /// To add a new device data point, provide enough natural key properties to uniquely identify it. Recommended properties include `identifier`, `type` and `observationDate`; these can be made into a unique combination for most device data points.
    /// - Parameters:
    ///   - dataPoints: A set of data points to persist.
    ///   - completion: Called when the request is complete, with an empty `.success` on success or an error on failure.
    public func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel], completion: @escaping (Result<Void, MyDataHelpsError>) -> Void) {
        load(resource: PersistDeviceDataResource(dataPoints: dataPoints), completion: completion)
    }
    
    // MARK: Surveys and tasks
    
    /// Query a list of tasks, often used to display a list of certain tasks to a participant.
    ///
    /// To fetch the first page of results, call this with a new `SurveyTaskQuery` object. If there are additional pages available, the next page can be fetched by using `SurveyTaskQuery.page(after:)` to construct a query for the following page.
    /// - Parameters:
    ///   - query: Specifies how to filter the data, and optionally which page of data to fetch.
    ///   - completion: Called when the request is complete, with a `SurveyTaskResultPage` instance on success or an error on failure. Results are ordered by the task creation date.
    public func querySurveyTasks(_ query: SurveyTaskQuery, completion: @escaping (Result<SurveyTaskResultPage, MyDataHelpsError>) -> Void) {
        load(resource: SurveyTaskQueryResource(query: query), completion: completion)
    }
    
    /// Retrieve past survey answers from QuestionSteps, FormSteps, or WebViewSteps. Often this is used to display past answers to the participant.
    ///
    /// To fetch the first page of results, call this with a new `SurveyAnswersQuery` object. If there are additional pages available, the next page can be fetched by using `SurveyAnswersQuery.page(after:)` to construct a query for the following page.
    /// - Parameters:
    ///   - query: Specifies how to filter the data, and optionally which page of data to fetch.
    ///   - completion: Called when the request is complete, with a `SurveyAnswersPage` instance on success or an error on failure. Results are ordered by answer date.
    public func querySurveyAnswers(_ query: SurveyAnswersQuery, completion: @escaping (Result<SurveyAnswersPage, MyDataHelpsError>) -> Void) {
        load(resource: SurveyAnswersQueryResource(query: query), completion: completion)
    }
    
    /// Deletes a survey result for a participant. This feature is only available for surveys with “Results Can Be Deleted” enabled. This option can be enabled from the Settings pane in RKStudio’s Survey Editor.
    ///
    /// This operation CANNOT be undone.
    /// - Parameters:
    ///   - surveyResultID: Auto-generated, globally-unique identifier for the survey submission to delete.
    ///   - completion: Called when the request is complete, with an empty `.success` on success or an error on failure.
    public func deleteSurveyResult(surveyResultID: String, completion: @escaping (Result<Void, MyDataHelpsError>) -> Void) {
        load(resource: DeleteSurveyResultResource(surveyResultID: surveyResultID), completion: completion)
    }
    
    // MARK: Notifications
    
    /// Queries the history of notifications sent to this participant.
    ///
    /// To fetch the first page of results, call this with a new `NotificationHistoryQuery` object. If there are additional pages available, the next page can be fetched by using `NotificationHistoryQuery.page(after:)` to construct a query for the following page.
    /// - Parameters:
    ///   - query: Specifies how to filter the data, and optionally which page of data to fetch.
    ///   - completion: Called when the request is complete, with a `NotificationHistoryPage` instance on success or an error on failure. Results are ordered by date.
    public func queryNotifications(_ query: NotificationHistoryQuery, completion: @escaping (Result<NotificationHistoryPage, MyDataHelpsError>) -> Void) {
        load(resource: NotificationHistoryQueryResource(query: query), completion: completion)
    }
}
