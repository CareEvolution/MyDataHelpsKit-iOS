# MyDataHelpsKit examples

A SwiftUI app demonstrating usage of MyDataHelpsKit. For more information about the MyDataHelpsKit SDK, see the main [readme file](https://github.com/CareEvolution/MyDataHelpsKit-iOS).

To get started, open `MyDataHelpsKit-Example.xcworkspace` in Xcode and run the app. Once the app launches, you will need to enter a valid participant token to authenticate and use the app's functionality. See [documentation on Participant Tokens](https://developer.rkstudio.careevolution.com/sdk/participant_tokens.html) for more information about obtaining an access token.

Once you enter a participant token, the example app initializes a `ParticipantSession` and displays the RootMenuView, from which you can navigate to various other views to demonstrate each of the MyDataHelpsKit APIs.

There are several ParticipantSession APIs that take query objects and produce paged arrays of results. These are all implemented in the example app with a generic `PagedView` SwiftUI view, and appropriate data source objects that perform the actual queries against ParticipantSession and construct individual SwiftUI views for each item in the results.

## Example app features

The headings below describe the functionality you can find in each subview accessed from the example app's main menu (`RootMenuView`):

### Participant Info

- After entering a valid participant token and proceeding to the main menu, the app immediately loads and displays the ParticipantInfo object via `ParticipantSession.getParticipantInfo`
- Modify `ParticipantInfoView` to experiment with displaying various ParticipantInfo properties or demographic fields

### Query Survey Tasks

- Demonstrates usage of `ParticipantSession.querySurveyTasks`. Modify the `SurveyTaskView.pageView` function to experiment with different query parameters
- Demonstrates `ParticipantSession.querySurveyAnswers`, by tapping on completed surveys
- Demonstrates embeddable survey functionality, by tapping on incomplete surveys. To use this feature, embeddable survey functionality must be enabled in RKStudio for the project and the survey

### Query Survey Answers

- Demonstrates general usage of `ParticipantSession.querySurveyAnswers`. Modify the `SurveyAnswerView.pageView` function to experiment with different query parameters
- Demonstrates deleting specific survey results, if deletion is enabled for the survey in RKStudio

### Device data

- **Device Data: Apple Health** and **Device Data: Project** demonstrates using `ParticipantSession.queryDeviceData` to query and list device data under the Apple Health or Project namespaces. Modify `RootMenuView` and the `DeviceDataPointView.pageView` function to experiment with different query parameters
- **Persist New Device Data** demonstrates creating and saving new device data in the Project namespace

### Query Notifications

- Demonstrates usage of `b`. Modify the `NotificationHistoryView.pageView` function to experiment with different query parameters
