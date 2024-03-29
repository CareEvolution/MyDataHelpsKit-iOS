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
/// Requests to the MyDataHelps platform are typically asynchronous. All asynchronous requests in ParticipantSession are implemented as Swift `async` functions. Async functions in `ParticipantSession` will throw errors for any failures in communicating with the MyDataHelps platform. All thrown errors are of type ``MyDataHelpsError``.
///
/// Read the [Programming Guide](https://developer.mydatahelps.org/ios/programming_guide.html) to understand general concepts and best practices for working with ParticipantSession and MyDataHelpsKit.
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
    /// - Returns: An asynchronously-delivered `ParticipantInfo` instance, if successful. Throws a `MyDataHelpsError` if unsuccessful.
    public func getParticipantInfo() async throws -> ParticipantInfo {
        try await load(resource: GetParticipantInfoResource())
    }
    
    /// Retrieves general project information.
    /// - Returns: An asynchronously-delivered `ProjectInfo` instance, if successful. Throws a `MyDataHelpsError` if unsuccessful.
    public func getProjectInfo() async throws -> ProjectInfo {
        try await load(resource: GetProjectInfoResource())
    }
    
    /// Retrieves settings related to data collection for the participant and their project.
    /// - Returns: An asynchronously-delivered `ProjectDataCollectionSettings` instance, if successful. Throws a `MyDataHelpsError` if unsuccessful.
    public func getDataCollectionSettings() async throws -> ProjectDataCollectionSettings {
        try await load(resource: GetProjectDataCollectionSettingsResource())
    }
    
    // MARK: Device data
    
    /// Queries device data for the participant.
    ///
    /// To fetch the first page of results, call this with a new `DeviceDataQuery` object. If there are additional pages available, the next page can be fetched by using `DeviceDataQuery.page(after:)` to construct a query for the following page.
    /// - Parameters:
    ///   - query: Specifies how to filter the data, and optionally which page of data to fetch.
    /// - Returns: An asynchronously-delivered `DeviceDataResultPage` instance, if successful. Throws a `MyDataHelpsError` if unsuccessful. Results are ordered by most recent date.
    public func queryDeviceData(_ query: DeviceDataQuery) async throws -> DeviceDataResultPage {
        try await load(resource: DeviceDataQueryResource(query: query))
    }
    
    /// Creates new and/or updates existing device data points. Each device data point is uniquely identified by a combination of its properties, called a natural key, as identified in `DeviceDataPointPersistModel`. Data points are always persisted with the `project` namespace.
    ///
    /// To update an existing device data point, persist one whose natural key properties exactly match the one to be updated. All non-natural key properties will be updated to your persisted point.
    ///
    /// To add a new device data point, provide enough natural key properties to uniquely identify it. Recommended properties include `identifier`, `type` and `observationDate`; these can be made into a unique combination for most device data points.
    /// - Parameters:
    ///   - dataPoints: A set of data points to persist.
    public func persistDeviceData(_ dataPoints: [DeviceDataPointPersistModel]) async throws {
        try await load(resource: PersistDeviceDataResource(dataPoints: dataPoints))
    }
    
    // MARK: Surveys and tasks
    
    /// Query a list of tasks, often used to display a list of certain tasks to a participant.
    ///
    /// To fetch the first page of results, call this with a new `SurveyTaskQuery` object. If there are additional pages available, the next page can be fetched by using `SurveyTaskQuery.page(after:)` to construct a query for the following page.
    /// - Parameters:
    ///   - query: Specifies how to filter the data, and optionally which page of data to fetch.
    /// - Returns: An asynchronously-delivered `SurveyTaskResultPage` instance, if successful. Throws a `MyDataHelpsError` if unsuccessful. Results are ordered by the task creation date.
    public func querySurveyTasks(_ query: SurveyTaskQuery) async throws -> SurveyTaskResultPage {
        try await load(resource: SurveyTaskQueryResource(query: query))
    }
    
    /// Retrieve past survey answers from QuestionSteps, FormSteps, or WebViewSteps. Often this is used to display past answers to the participant.
    ///
    /// To fetch the first page of results, call this with a new `SurveyAnswersQuery` object. If there are additional pages available, the next page can be fetched by using `SurveyAnswersQuery.page(after:)` to construct a query for the following page.
    /// - Parameters:
    ///   - query: Specifies how to filter the data, and optionally which page of data to fetch.
    /// - Returns: An asynchronously-delivered `SurveyAnswersPage`, if successful. Throws a `MyDataHelpsError` if unsuccessful. Results are ordered by answer date.
    public func querySurveyAnswers(_ query: SurveyAnswersQuery) async throws -> SurveyAnswersPage {
        try await load(resource: SurveyAnswersQueryResource(query: query))
    }
    
    /// Deletes a survey result for a participant. This feature is only available for surveys with “Results Can Be Deleted” enabled. This option can be enabled from the survey editor Settings pane in MyDataHelps Designer.
    ///
    /// This operation CANNOT be undone.
    /// - Parameters:
    ///   - surveyResultID: Auto-generated, globally-unique identifier for the survey submission to delete.
    public func deleteSurveyResult(_ surveyResultID: SurveyResult.ID) async throws {
        try await load(resource: DeleteSurveyResultResource(surveyResultID: surveyResultID))
    }
    
    // MARK: Notifications
    
    /// Queries the history of notifications sent to this participant.
    ///
    /// To fetch the first page of results, call this with a new `NotificationHistoryQuery` object. If there are additional pages available, the next page can be fetched by using `NotificationHistoryQuery.page(after:)` to construct a query for the following page.
    /// - Parameters:
    ///   - query: Specifies how to filter the data, and optionally which page of data to fetch.
    /// - Returns: An asynchronously-delivered `NotificationHistoryPage` instance, if successful. Throws a `MyDataHelpsError` if unsuccessful. Results are ordered by date.
    public func queryNotifications(_ query: NotificationHistoryQuery) async throws -> NotificationHistoryPage {
        try await load(resource: NotificationHistoryQueryResource(query: query))
    }
}
