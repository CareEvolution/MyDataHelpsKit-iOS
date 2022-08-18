//
//  SurveyTasks.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/26/21.
//

import Foundation

/// Container for the `Survey.ID` identifier type, which identifies a specific survey in MyDataHelps.
///
/// The ``Survey`` struct itself is empty and no instances are returned by any APIs.
public struct Survey {
    /// Identifies a specific survey in MyDataHelps.
    ///
    /// Used for ``SurveyTask`` and ``SurveyAnswer`` values, and related APIs.
    public typealias ID = ScopedIdentifier<Survey, String>
}

/// Container for the `SurveyResult.ID` identifier type, which identifies a specific survey submission in MyDataHelps.
///
/// The ``Survey`` struct itself is empty and no instances are returned by any APIs.
public struct SurveyResult {
    /// Identifies a specific survey submission in MyDataHelps.
    ///
    /// Used for ``SurveyAnswer`` values and related APIs.
    public typealias ID = ScopedIdentifier<SurveyResult, String>
}

/// Specifies filtering and page-navigation criteria for survey task queries.
///
/// All query properties are optional. Set non-nil/non-default values only for the properties you want to use for filtering or sorting.
public struct SurveyTaskQuery: PagedQuery {
    /// Specifies sorting order for survey task results.
    public enum SortOrder: String, Codable {
        /// Sort by task creation date, with oldest date first.
        case dateAscending = "Ascending"
        /// Sort by task creation date, with most recent date first.
        case dateDescending = "Descending"
    }
    
    /// The default and maximum number of results per page.
    public static let defaultLimit = 100

    /// Filter by one or more survey task status values.
    public let statuses: Set<SurveyTaskStatus>?
    /// Auto-generated, globally-unique identifier for the survey which this task assigns.
    public let surveyID: Survey.ID?
    /// Internal name for the survey in MyDataHelps which this task assigns. Filter by one or more values.
    public let surveyNames: Set<String>?
    /// Secure and unique identifier for the task, to be used publicly when providing links to a survey.
    public let linkIdentifier: SurveyTaskLink.ID?
    /// Return results in the specified order. Defaults to `dateDescending`.
    public let sortOrder: SortOrder?
    
    /// Maximum number of results per page. Default and maximum value is 100.
    public let limit: Int
    /// Identifies a specific page of survey tasks to fetch. Use `nil` to fetch the first page of results. To fetch the page following a given `SurveyTaskResultPage` use its `nextPageID`; the other parameters should be the same as the original `SurveyTaskQuery`.
    public let pageID: SurveyTaskResultPage.PageID?
    
    /// Initializes a new query for a page of survey tasks with various filters.
    /// - Parameters:
    ///   - statuses: Filter by one or more survey task status values.
    ///   - surveyID: Auto-generated, globally-unique identifier for the survey which this task assigns.
    ///   - surveyNames: Internal name for the survey in MyDataHelps which this task assigns.
    ///   - linkIdentifier: Secure and unique identifier for the task, to be used publicly when providing links to a survey.
    ///   - sortOrder: Return results in the specified order.
    ///   - limit: Maximum number of results per page.
    ///   - pageID: Identifies a specific page of survey tasks to fetch.
    public init(statuses: Set<SurveyTaskStatus>? = nil, surveyID: Survey.ID? = nil, surveyNames: Set<String>? = nil, linkIdentifier: SurveyTaskLink.ID? = nil, sortOrder: SurveyTaskQuery.SortOrder? = nil, limit: Int = defaultLimit, pageID: SurveyTaskResultPage.PageID? = nil) {
        self.statuses = statuses
        self.surveyID = surveyID
        self.surveyNames = surveyNames
        self.linkIdentifier = linkIdentifier
        self.sortOrder = sortOrder
        self.limit = Self.clampedLimit(limit, max: Self.defaultLimit)
        self.pageID = pageID
    }
    
    /// Initializes a new query for a page of results following the given page, with the same filters as the original query.
    /// - Parameter page: The previous page of results, which should have been produced with this query.
    /// - Returns: A query for results following `page`, if page has a `nextPageID`. If there are no additional pages of results available, returns `nil`. The query returned, if any, has the same filters as the original.
    public func page(after page: SurveyTaskResultPage) -> SurveyTaskQuery? {
        guard let nextPageID = page.nextPageID else { return nil }
        return SurveyTaskQuery(statuses: statuses, surveyID: surveyID, surveyNames: surveyNames, linkIdentifier: linkIdentifier, sortOrder: sortOrder, limit: limit, pageID: nextPageID)
    }
}

/// A page of survey tasks.
public struct SurveyTaskResultPage: PagedResult, Decodable {
    /// Identifies a specific page of survey tasks.
    public typealias PageID = ScopedIdentifier<SurveyTaskResultPage, String>
    /// A list of SurveyTasks filtered by the query criteria.
    public let surveyTasks: [SurveyTask]
    /// An ID to be used with subsequent `SurveyTaskQuery` requests. Results from queries using this ID as the `pageID` parameter will show the next page of results. `nil` if there isn't a next page.
    public let nextPageID: PageID?
}

/// Describes the status of a survey task assigned to a participant.
public struct SurveyTaskStatus: RawRepresentable, Equatable, Hashable, Decodable {
    public typealias RawValue = String
    
    /// Task is open and incomplete.
    public static let incomplete = SurveyTaskStatus(rawValue: "incomplete")
    /// Task was completed.
    public static let complete = SurveyTaskStatus(rawValue: "complete")
    /// Task was closed without being completed.
    public static let closed = SurveyTaskStatus(rawValue: "closed")
    
    /// The raw value for the task status as stored in MyDataHelps.
    public let rawValue: String
    
    /// Initializes a `SurveyTaskStatus` with an arbitrary value. Consider using static members such as `SurveyTaskStatus.incomplete` instead for known values.
    /// - Parameter rawValue: The raw value for the task status as stored in MyDataHelps.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Container for the `SurveyTaskLink.ID` identifier type, which is used for generating links to a survey.
///
/// The ``SurveyTaskLink`` struct itself is empty and no instances are returned by any APIs.
public struct SurveyTaskLink {
    /// Secure and unique identifier for a SurveyTask, to be used publicly when providing links to a survey.
    public typealias ID = ScopedIdentifier<SurveyTaskLink, String>
}

/// A single survey task assigned to a participant.
public struct SurveyTask: Identifiable, Decodable {
    /// Auto-generated, globally-unique identifier for a SurveyTask.
    public typealias ID = ScopedIdentifier<SurveyTask, String>
    
    /// Auto-generated, globally-unique identifier.
    public let id: ID
    /// Secure and unique identifier for the task, to be used publicly when providing links to a survey.
    public let linkIdentifier: SurveyTaskLink.ID?
    /// Auto-generated, globally-unique identifier for the survey which this task assigns.
    public let surveyID: Survey.ID
    /// Internal name for the survey in MyDataHelps which this task assigns.
    public let surveyName: String
    /// Name of the survey displayed to the participant, which this task assigns.
    public let surveyDisplayName: String
    /// Brief explanation of the survey provided to the participant.
    public let surveyDescription: String
    /// Initial time the task is available to the participant.
    public let startDate: Date?
    /// Time at which the task becomes unavailable to the participant, because it was completed or closed.
    public let endDate: Date?
    /// Describes the status of the survey task.
    public let status: SurveyTaskStatus
    /// Indicates that the participant has opened the assigned survey and submitted at least one answer, without completing the task.
    public let hasSavedProgress: Bool
    /// Time that the survey becomes past due and closed.
    public let dueDate: Date?
    /// Date when the survey task was first created.
    public let insertedDate: Date
    /// Date when the survey task was last modified.
    public let modifiedDate: Date
}
