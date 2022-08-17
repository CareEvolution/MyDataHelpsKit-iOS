//
//  SurveyAnswers.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/19/21.
//

import Foundation

/// Specifies filtering and page-navigation criteria for survey answers.
///
/// All query properties are optional. Set non-nil/non-default values only for the properties you want to use for filtering.
///
/// You can filter survey answers by two different types of dates: `before/after` and `insertedBefore/After`. The former properties use the date the answer was recorded by the participant; the latter ones use the date the answer was submitted to the system. The dates may be appreciably different if the participant started a survey, answered a few questions, and then submitted it much later. There may also be minor variations due to the participant's device time compared to the server time. Use the `insertedAfter` property to search for new answers since a prior query.
public struct SurveyAnswersQuery: PagedQuery {
    /// The default and maximum number of results per page.
    public static let defaultLimit = 100
    
    /// Auto-generated, globally-unique identifier for the survey submission containing the answer.
    public let surveyResultID: SurveyResult.ID?
    /// Auto-generated, globally-unique identifier for the survey containing the step the answer was provided for.
    public let surveyID: Survey.ID?
    /// Filter by one or more internal names of the surveys which have the answers.
    public let surveyNames: Set<String>?
    /// Search for answers recorded by the participant after a specific date.
    public let after: Date?
    /// Search for answers recorded by the participant before a specific date.
    public let before: Date?
    /// Search for answers submitted to the system after a specific date.
    public let insertedAfter: Date?
    /// Search for answers submitted to the system before a specific date.
    public let insertedBefore: Date?
    /// Filter by one or more identifiers for the survey steps for which answers were submitted. Refers to the step identifier field in the MyDataHelps survey editor.
    public let stepIdentifiers: Set<String>?
    /// Filter by one or more identifiers for the field on the survey step for which answers were submitted. Relevant for form steps, and refers to their form items’ identifier field.
    public let resultIdentifiers: Set<String>?
    /// Filter by one or more specific text values the answer contains.
    public let answers: Set<String>?
    
    /// Maximum number of results per page. Default and maximum value is 100.
    public let limit: Int
    /// Identifies a specific page of survey answers to fetch. Use `nil` to fetch the first page of results. To fetch the page following a given `SurveyAnswersPage` use its `nextPageID`; the other parameters should be the same as the original `SurveyAnswersQuery`.
    public let pageID: SurveyAnswersPage.PageID?
    
    /// Initializes a new query for a page of survey answers with various filters.
    /// - Parameters:
    ///   - surveyResultID: Auto-generated, globally-unique identifier for the survey submission containing the answer.
    ///   - surveyID: Auto-generated, globally-unique identifier for the survey containing the step the answer was provided for.
    ///   - surveyNames: Filter by one or more internal names of the surveys which have the answers.
    ///   - after: Search for answers recorded by the participant after a specific date.
    ///   - before: Search for answers recorded by the participant before a specific date.
    ///   - insertedAfter: Search for answers submitted to the system after a specific date.
    ///   - insertedBefore: Search for answers submitted to the system before a specific date.
    ///   - stepIdentifiers: Filter by one or more identifiers for the survey steps for which answers were submitted. Refers to the step identifier field in the MyDataHelps survey editor.
    ///   - resultIdentifiers: Filter by one or more identifiers for the field on the survey step for which answers were submitted. Relevant for form steps, and refers to their form items’ identifier field.
    ///   - answers: Filter by one or more specific text values the answer contains.
    ///   - limit: Maximum number of results per page.
    ///   - pageID: Identifies a specific page of survey answers to fetch.
    public init(surveyResultID: SurveyResult.ID? = nil, surveyID: Survey.ID? = nil, surveyNames: Set<String>? = nil, after: Date? = nil, before: Date? = nil, insertedAfter: Date? = nil, insertedBefore: Date? = nil, stepIdentifiers: Set<String>? = nil, resultIdentifiers: Set<String>? = nil, answers: Set<String>? = nil, limit: Int = defaultLimit, pageID: SurveyAnswersPage.PageID? = nil) {
        self.surveyResultID = surveyResultID
        self.surveyID = surveyID
        self.surveyNames = surveyNames
        self.after = after
        self.before = before
        self.insertedAfter = insertedAfter
        self.insertedBefore = insertedBefore
        self.stepIdentifiers = stepIdentifiers
        self.resultIdentifiers = resultIdentifiers
        self.answers = answers
        self.limit = Self.clampedLimit(limit, max: Self.defaultLimit)
        self.pageID = pageID
    }
    
    /// Initializes a new query for a page of results following the given page, with the same filters as the original query.
    /// - Parameter page: The previous page of results, which should have been produced with this query.
    /// - Returns: A query for results following `page`, if page has a `nextPageID`. If there are no additional pages of results available, returns `nil`. The query returned, if any, has the same filters as the original.
    public func page(after page: SurveyAnswersPage) -> SurveyAnswersQuery? {
        guard let nextPageID = page.nextPageID else { return nil }
        return SurveyAnswersQuery(surveyResultID: surveyResultID, surveyID: surveyID, surveyNames: surveyNames, after: after, before: before, insertedAfter: insertedAfter, insertedBefore: insertedBefore, stepIdentifiers: stepIdentifiers, resultIdentifiers: resultIdentifiers, answers: answers, limit: limit, pageID: nextPageID)
    }
}

/// A page of survey answers.
public struct SurveyAnswersPage: PagedResult, Decodable {
    /// Identifies a specific page of survey answers.
    public typealias PageID = ScopedIdentifier<SurveyAnswersPage, String>
    /// A list of SurveyAnswers filtered by the query criteria.
    public let surveyAnswers: [SurveyAnswer]
    /// An ID to be used with subsequent `SurveyAnswersQuery` requests. Results from queries using this ID as the `pageID` parameter will show the next page of results. `nil` if there isn't a next page.
    public let nextPageID: PageID?
}

/// A single survey answer completed by a participant.
public struct SurveyAnswer: Identifiable, Decodable {
    /// Auto-generated, globally-unique identifier for a SurveyAnswer.
    public typealias ID = ScopedIdentifier<SurveyAnswer, String>
    
    /// Auto-generated, globally-unique identifier.
    public let id: ID
    /// Auto-generated, globally-unique identifier for the survey submission containing this answer.
    public let surveyResultID: SurveyResult.ID
    /// Auto-generated, globally-unique identifier for the survey containing the step this answer was provided for.
    public let surveyID: Survey.ID
    /// Version number of the survey that the participant completed.
    public let surveyVersion: Int
    /// Auto-generated, globally-unique identifier for the task which prompted the participant to complete the survey, if any.
    public let taskID: String?
    /// Internal name for the survey in MyDataHelps.
    public let surveyName: String
    /// Name of the survey displayed to the participant.
    public let surveyDisplayName: String
    /// Date and time at which the survey answer was recorded by the participant.
    public let date: Date?
    /// Date and time at which the was submitted to the system.
    public let insertedDate: Date
    /// Identifier for the survey step for which the answer was submitted.
    public let stepIdentifier: String
    /// Identifier for the field on the survey step which contains this survey answer.
    public let resultIdentifier: String
    /// List of answers contained in the result for this step of the survey.
    public let answers: [String]
}
