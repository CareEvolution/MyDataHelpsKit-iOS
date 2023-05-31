//
//  SurveyModelsTests.swift
//  MyDataHelpsKitTests
//
//  Created by CareEvolution on 3/16/23.
//

import XCTest
@testable import MyDataHelpsKit

final class SurveyModelsTests: XCTestCase {
    func testSurveyTaskResultPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(SurveyTaskResultPage.self, from: surveyTaskResultPageJSON)
        XCTAssertEqual(page.nextPageID, nextPageID1)
        XCTAssertEqual(page.surveyTasks.count, 3)
        
        guard page.surveyTasks.count == 3 else { return }
        
        var task = page.surveyTasks[0]
        XCTAssertEqual(task.id, taskID1)
        XCTAssertEqual(task.surveyID, surveyID1)
        XCTAssertEqual(task.surveyName, "SurveyName1")
        XCTAssertEqual(task.surveyDisplayName, "Survey Display Name 1")
        XCTAssertEqual(task.surveyDescription, "Description 1")
        XCTAssertNil(task.startDate)
        XCTAssertNil(task.endDate)
        XCTAssertEqual(task.status, .incomplete)
        XCTAssertFalse(task.hasSavedProgress)
        XCTAssertEqual(task.dueDate?.formatted(.iso8601), "2023-03-28T20:42:07Z")
        XCTAssertEqual(task.insertedDate.formatted(.iso8601), "2023-03-14T20:42:07Z")
        XCTAssertEqual(task.modifiedDate.formatted(.iso8601), "2023-03-14T20:42:07Z")
        
        task = page.surveyTasks[1]
        XCTAssertEqual(task.id, taskID2)
        XCTAssertEqual(task.surveyID, surveyID1)
        XCTAssertEqual(task.surveyName, "SurveyName1")
        XCTAssertEqual(task.surveyDisplayName, "Survey Display Name 1")
        XCTAssertEqual(task.surveyDescription, "Description 1")
        XCTAssertEqual(task.startDate?.formatted(.iso8601), "2023-03-14T20:38:00Z")
        XCTAssertEqual(task.endDate?.formatted(.iso8601), "2023-03-14T20:38:36Z")
        XCTAssertEqual(task.status, .complete)
        XCTAssertFalse(task.hasSavedProgress)
        XCTAssertEqual(task.dueDate?.formatted(.iso8601), "2023-03-28T20:35:49Z")
        XCTAssertEqual(task.insertedDate.formatted(.iso8601), "2023-03-14T20:35:49Z")
        XCTAssertEqual(task.modifiedDate.formatted(.iso8601), "2023-03-14T20:38:37Z")
        
        task = page.surveyTasks[2]
        XCTAssertEqual(task.id, taskID3)
        XCTAssertEqual(task.surveyID, surveyID2)
        XCTAssertEqual(task.surveyName, "SurveyName2")
        XCTAssertEqual(task.surveyDisplayName, "Survey Display Name 2")
        XCTAssertEqual(task.surveyDescription, "")
        XCTAssertNil(task.startDate)
        XCTAssertNil(task.endDate)
        XCTAssertEqual(task.status, .incomplete)
        XCTAssertTrue(task.hasSavedProgress)
        XCTAssertNil(task.dueDate)
        XCTAssertEqual(task.insertedDate.formatted(.iso8601), "2023-03-07T20:44:45Z")
        XCTAssertEqual(task.modifiedDate.formatted(.iso8601), "2023-03-15T13:52:26Z")
    }
    
    func testEmptySurveyTaskResultPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(SurveyTaskResultPage.self, from: emptySurveyTaskResultPageJSON)
        XCTAssertNil(page.nextPageID)
        XCTAssertTrue(page.surveyTasks.isEmpty)
    }
    
    func testSurveyAnswersPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(SurveyAnswersPage.self, from: surveyAnswersPageJSON)
        XCTAssertEqual(page.nextPageID, nextPageID2)
        XCTAssertEqual(page.surveyAnswers.count, 3)
        
        guard page.surveyAnswers.count == 3 else { return }
        
        var answer = page.surveyAnswers[0]
        XCTAssertEqual(answer.id, answerID1)
        XCTAssertEqual(answer.surveyResultID, surveyResultID1)
        XCTAssertEqual(answer.surveyID, surveyID1)
        XCTAssertEqual(answer.surveyVersion, 0)
        XCTAssertEqual(answer.taskID, taskID2)
        XCTAssertEqual(answer.surveyName, "SurveyName1")
        XCTAssertEqual(answer.surveyDisplayName, "Survey Display Name 1")
        XCTAssertEqual(answer.date?.formatted(.iso8601), "2023-03-15T14:26:11Z")
        XCTAssertEqual(answer.insertedDate.formatted(.iso8601), "2023-03-15T14:26:13Z")
        XCTAssertEqual(answer.stepIdentifier, "Step 1")
        XCTAssertEqual(answer.resultIdentifier, "Step 1")
        XCTAssertEqual(answer.answers, ["3"])
        
        answer = page.surveyAnswers[1]
        XCTAssertEqual(answer.id, answerID2)
        XCTAssertEqual(answer.surveyResultID, surveyResultID2)
        XCTAssertEqual(answer.surveyID, surveyID2)
        XCTAssertEqual(answer.surveyVersion, 19)
        XCTAssertNil(answer.taskID)
        XCTAssertEqual(answer.surveyName, "SurveyName2")
        XCTAssertEqual(answer.surveyDisplayName, "Survey Display Name 2")
        XCTAssertEqual(answer.date?.formatted(.iso8601), "2023-03-15T14:24:53Z")
        XCTAssertEqual(answer.insertedDate.formatted(.iso8601), "2023-03-15T14:24:53Z")
        XCTAssertEqual(answer.stepIdentifier, "FormStep1")
        XCTAssertEqual(answer.resultIdentifier, "FormStep1Item1")
        XCTAssertEqual(answer.answers, ["2", "4"])
        
        answer = page.surveyAnswers[2]
        XCTAssertEqual(answer.id, answerID3)
        XCTAssertEqual(answer.surveyResultID, surveyResultID2)
        XCTAssertEqual(answer.surveyID, surveyID2)
        XCTAssertEqual(answer.surveyVersion, 19)
        XCTAssertNil(answer.taskID)
        XCTAssertEqual(answer.surveyName, "SurveyName2")
        XCTAssertEqual(answer.surveyDisplayName, "Survey Display Name 2")
        XCTAssertNil(answer.date)
        XCTAssertEqual(answer.insertedDate.formatted(.iso8601), "2023-03-15T14:24:53Z")
        XCTAssertEqual(answer.stepIdentifier, "WebViewStep1")
        XCTAssertEqual(answer.resultIdentifier, "WebViewStep1")
        XCTAssertEqual(answer.answers, [])
    }
    
    func testEmptySurveyAnswersPageJSONDecodes() throws {
        let page = try JSONDecoder.myDataHelpsDecoder.decode(SurveyAnswersPage.self, from: emptySurveyAnswersPageJSON)
        XCTAssertNil(page.nextPageID)
        XCTAssertTrue(page.surveyAnswers.isEmpty)
    }
    
    private let nextPageID1 = SurveyTaskResultPage.PageID(UUID().uuidString)
    private let nextPageID2 = SurveyAnswersPage.PageID(UUID().uuidString)
    private let taskID1 = SurveyTask.ID(UUID().uuidString)
    private let taskID2 = SurveyTask.ID(UUID().uuidString)
    private let taskID3 = SurveyTask.ID(UUID().uuidString)
    private let surveyID1 = Survey.ID(UUID().uuidString)
    private let surveyID2 = Survey.ID(UUID().uuidString)
    private let answerID1 = SurveyAnswer.ID(UUID().uuidString)
    private let answerID2 = SurveyAnswer.ID(UUID().uuidString)
    private let answerID3 = SurveyAnswer.ID(UUID().uuidString)
    private let surveyResultID1 = SurveyResult.ID(UUID().uuidString)
    private let surveyResultID2 = SurveyResult.ID(UUID().uuidString)

    private var surveyTaskResultPageJSON: Data { """
{
  "surveyTasks": [
    {
      "id": "\(taskID1)",
      "surveyID": "\(surveyID1)",
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
      "id": "\(taskID2)",
      "surveyID": "\(surveyID1)",
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
      "id": "\(taskID3)",
      "surveyID": "\(surveyID2)",
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
  "nextPageID": "\(nextPageID1)"
}
""".data(using: .utf8)! }
    
    private var emptySurveyTaskResultPageJSON: Data {
        """
{
  "surveyTasks": [
  ],
  "nextPageID": null
}
""".data(using: .utf8)! }
    
    private var surveyAnswersPageJSON: Data { """
{
  "surveyAnswers": [
    {
      "id": "\(answerID1)",
      "surveyResultID": "\(surveyResultID1)",
      "surveyID": "\(surveyID1)",
      "surveyVersion": 0,
      "taskID": "\(taskID2)",
      "surveyName": "SurveyName1",
      "surveyDisplayName": "Survey Display Name 1",
      "date": "2023-03-15T10:26:11.428-04:00",
      "stepIdentifier": "Step 1",
      "resultIdentifier": "Step 1",
      "answers": [
        "3"
      ],
      "insertedDate": "2023-03-15T14:26:13.753Z"
    },
    {
      "id": "\(answerID2)",
      "surveyResultID": "\(surveyResultID2)",
      "surveyID": "\(surveyID2)",
      "surveyVersion": 19,
      "taskID": null,
      "surveyName": "SurveyName2",
      "surveyDisplayName": "Survey Display Name 2",
      "date": "2023-03-15T10:24:53.775-04:00",
      "stepIdentifier": "FormStep1",
      "resultIdentifier": "FormStep1Item1",
      "answers": [
        "2", "4"
      ],
      "insertedDate": "2023-03-15T14:24:53.953Z"
    },
    {
      "id": "\(answerID3)",
      "surveyResultID": "\(surveyResultID2)",
      "surveyID": "\(surveyID2)",
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
  "nextPageID": "\(nextPageID2)"
}
""".data(using: .utf8)! }
    
    private var emptySurveyAnswersPageJSON: Data {
        """
{
  "surveyAnswers": [
  ],
  "nextPageID": null
}
""".data(using: .utf8)! }

}
