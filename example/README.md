# MyDataHelpsKit examples

A SwiftUI app demonstrating usage of MyDataHelpsKit. For more information about the MyDataHelpsKit SDK, see the main [readme file](https://github.com/CareEvolution/MyDataHelpsKit-iOS).

To get started, open `MyDataHelpsKit-Example.xcworkspace` in Xcode and run the app. Once the app launches, you will need to enter a valid participant token to authenticate and use the app's functionality. See [documentation on Participant Tokens](https://developer.mydatahelps.org/embeddables/participant_tokens.html) for more information about obtaining an access token.

Once you enter a participant token, the example app initializes a `ParticipantSession` and displays the RootMenuView, from which you can navigate to various other views to demonstrate each of the MyDataHelpsKit APIs.

There are several ParticipantSession APIs that take query objects and produce paged arrays of results. These are all implemented in the example app with a generic `PagedView` SwiftUI view, and appropriate data source objects that perform the actual queries against ParticipantSession and construct individual SwiftUI views for each item in the results.

## Using this app to learn about MyDataHelpsKit

Browse the example app source code to see how a real app might use the MyDataHelpsKit SDK. Search the example code for `/// triple-slash comments` for inline explanation of how MyDataHelpsKit is being used. Try customizing the example app's code to experiment with different ways to call various APIs: search for code comments labeled `EXERCISE` for suggested customization points.

## Example app features

The headings below describe the functionality you can find in each subview accessed from the example app's main menu (RootMenuView):

### Participant/Project Info

- After entering a valid participant token and proceeding to the main menu, the app immediately loads and displays the ParticipantInfo object via `ParticipantSession.getParticipantInfo`.
- Modify `ParticipantInfoView` to experiment with displaying various ParticipantInfo properties or demographic fields.
- Similarly, project info and data collection settings retrieved via `ParticipantSession.getProjectInfo` and `ParticipantSession.getDataCollectionSettings` are displayed in a `ProjectInfoView`; modify this view to explore the various data available in project info or data settings.

### Query Survey Tasks

- Demonstrates usage of `ParticipantSession.querySurveyTasks`. Modify the `SurveyTaskView.pageView` function to experiment with different query parameters.
- Demonstrates `ParticipantSession.querySurveyAnswers`, by tapping on completed surveys.

### Query Survey Answers

- Demonstrates general usage of `ParticipantSession.querySurveyAnswers`. Modify the `SurveyAnswerView.pageView` function to experiment with different query parameters.
- Demonstrates deleting specific survey results, if deletion is enabled for the survey in MyDataHelps.

### Device Data

- **Device Data: Apple Health** and **Device Data: Project** demonstrates using `ParticipantSession.queryDeviceData` to query and list device data under the Apple Health or Project namespaces. Modify `RootMenuView` and the `DeviceDataPointView.pageView` function to experiment with different query parameters.
- **Persist New Device Data** demonstrates creating and saving new device data in the Project namespace.

### Query Notifications

- Demonstrates usage of `ParticipantSession.queryNotifications`. Modify the `NotificationHistoryView.pageView` function to experiment with different query parameters. `NotificationHistoryView.Model` demonstrates various ways to access the different types of notification content available.

### MyDataHelps Surveys

- **Survey Launcher** demonstrates presentation of MyDataHelps surveys from within your app. Tap on "Survey Launcher" and enter a survey name from your MyDataHelps project (found in MyDataHelps Designer). See the documentation for `SurveyViewController` for more information on usage and links to relevant MyDataHelps documentation.

### External Accounts

- The top level External Accounts screen demonstrates usage of `ParticipantSession.listExternalAccounts` to view, update, and delete connected external account providers.
- Tap the `+` button on that screen to view available external account providers via `ParticipantSession.queryExternalAccountProviders`. Modify the call to `ExternalAccountProviderView.pageView` in ExternalAccountsListView.swift to experiment with different query parameters.
- Selecting an external account provider demonstrates the provider connection authorization flow, using `ParticipantSession.connectExternalAccount` to initiate the connection, and `SFSafariViewController` to present the UI. Note that MyDataHelpsKit only supplies a URL to present, your app (as demonstrated by the example app) is responsible for presenting a Safari view with that URL to the participant, and dismissing the Safari view by intercepting a special link. See `ParticipantSession.connectExternalAccount` documentation for details.
