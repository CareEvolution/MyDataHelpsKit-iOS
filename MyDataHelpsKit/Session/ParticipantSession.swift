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
/// Requests to the MyDataHelps platform are typically asynchronous. All asynchronous requests in ParticipantSession are implemented as Swift `async` functions. These functions suspend the calling thread until the request is complete, and then return the result object (if applicable). ParticipantSession performs the actual requests and all response parsing in a background thread, and makes no guarantee about the specific thread the result is returned on.
///
/// The caller is responsible for controlling the thread in which the async continuation occurs; the calling Task, function, or class should be marked as `@MainActor` if it updates the app's UI, as shown in the examples below.
///
/// ### Error Handling
///
/// Async functions in `ParticipantSession` will throw errors for any failures in communicating with the MyDataHelps platform. All thrown errors are of type ``MyDataHelpsError``. `MyDataHelpsError` provides a convenience initializer to simplify `do/catch` blocks, as shown in the examples below.
///
/// ### Examples
///
/// Using ParticipantSession's async APIs and errors in SwiftUI (see the [MyDataHelpsKit example app](https://github.com/CareEvolution/MyDataHelpsKit-iOS/tree/main/example) for additional SwiftUI examples):
///
///     @MainActor class ParticipantInfoViewModel: ObservableObject {
///         let session: ParticipantSession
///         @Published var name: String?
///         @Published var error: MyDataHelpsError?
///         func fetch() async {
///             do {
///                 // ParticipantInfoViewModel is marked as @MainActor, guaranteeing the
///                 // name value (or any thrown error) will be set on the main thread.
///                 name = try await session.getParticipantInfo().demographics.firstName
///             } catch {
///                 // This safely casts the thrown error to a MyDataHelpsError
///                 // without an extra 'catch let...as...' block.
///                 error = MyDataHelpsError(error)
///             }
///         }
///     }
///
/// Using ParticipantSession's async APIs and errors in UIKit:
///
///     class ParticipantInfoViewController: UIViewController {
///         let session: ParticipantSession
///         @IBOutlet var nameLabel: UILabel!
///         @IBOutlet var errorLabel: UILabel!
///         func viewDidLoad() {
///             // Mark the Task as @MainActor to guarantee the UI
///             // (or any thrown error) will be updated on the main thread.
///             Task { @MainActor in
///                 do {
///                     let name = try await self.session.getParticipantInfo().demographics.firstName
///                     self.nameLabel.text = name
///                 } catch {
///                     // This safely casts the thrown error to a MyDataHelpsError
///                     // without an extra 'catch let...as...' block.
///                     self.errorLabel.text = MyDataHelpsError(error).localizedDescription
///                 }
///             }
///         }
///     }
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
    
    // MARK: Participant info
    
    /// Retrieves basic information about the participant.
    /// - Returns: An asynchronously-delivered `ParticipantInfo` instance, if successful. Throws a `MyDataHelpsError` if unsuccessful.
    public func getParticipantInfo() async throws -> ParticipantInfo {
        try await load(resource: GetParticipantInfoResource())
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
    
    /// Creats new and/or updates existing device data points. Each device data point is uniquely identified by a combination of its properties, called a natural key, as identified in `DeviceDataPointPersistModel`. Data points are always persisted with the `project` namespace.
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
