# MyDataHelpsKit examples

A SwiftUI app demonstrating usage of MyDataHelpsKit. For more information about the MyDataHelpsKit SDK, see the main [readme file](https://github.com/CareEvolution/MyDataHelpsKit-iOS). This app is designed to exercise every API offered by MyDataHelpsKit so you can immediately get familiar with the capabilities of this SDK without writing any code, and you're encouraged to modify your local copy of the example app to experiment with the functionality.

To get started, [clone this repo](https://github.com/CareEvolution/MyDataHelpsKit-iOS) or download the [latest release](https://github.com/CareEvolution/MyDataHelpsKit-iOS/releases/latest). Open `MyDataHelpsKit-Example.xcworkspace` in Xcode. This workspace includes the example app and a local reference to the MyDataHelpsKit SDK (when you build your own app, make sure to correctly [install](https://developer.mydatahelps.org/ios/installation.html) MyDataHelpsKit using Swift Package Manager or other supported techniques).

After you launch the example app, you will need to enter a valid participant token to authenticate and use the app's functionality. See [documentation on Participant Tokens](https://developer.mydatahelps.org/embeddables/participant_tokens.html) for more information about obtaining an access token. Once you enter a participant token, the example app initializes a `ParticipantSession` and displays a set of tabs that show how you can use each of the MyDataHelpsKit APIs to build various app features for your participants.

## Using this app to learn about MyDataHelpsKit

Browse the example app source code to see how a real app might use the MyDataHelpsKit SDK. Search the example code for `/// triple-slash comments` for inline explanations of how MyDataHelpsKit is being used.

Try customizing the example app's code to experiment with the data available and with different ways to use the various APIs before you begin building your own app. Search for code comments labeled `/// EXERCISE` for suggested customization points. Use the SwiftUI Preview functionality in Xcode to see how the views should look with valid data, to confirm that the example app is working correctly at runtime with your participant token, project configuration, and any code modifications you have made.

Once you have a service account and API hosting configured for authenticating participants and generating participant tokens, you could customize `TokenView` and `SessionModel` to integrate with your authentication endpoint to facilitate further exploration of your live participant and project data using MyDataHelpsKit before building your own app.

## Example app features

The headings below describe the functionality you can find in each tab in the example app:

### "Tasks" tab
Implemented by `TasksView` and `TasksViewModel`.

- Displays assigned, incomplete survey tasks using `SurveyTaskQuery`.
- Lists all previously completed survey tasks using another `SurveyTaskQuery` with different filtering parameters. Tapping a completed task uses `SurveyAnswersQuery` to show individual answers submitted for the selected survey. Answers can be deleted from that view, if the survey is configured in MyDataHelps Designer to allow deletion of submitted answers.
- Uses MyDataHelpsKit's `SurveyViewController` to display a MyDataHelps survey within the app, in two different ways:
    - Selecting an incomplete survey task will launch the survey associated with that assigned task.
    - Any survey published to your project can also be launched by name, rather than by task. This could be used, for example, to present recurring surveys to your participant every day. Experiment with this by modifying the `TasksViewModel.persistentSurveys` array to include surveys available to your project, or use `SurveyLauncherView` to simply enter a survey name at runtime. Log in to MyDataHelps Designer to find the surveys published to your project and the survey name configured for each survey.

`SurveyViewController` is a UIViewController provided by MyDataHelpsKit that handles the complete user experience for a MyDataHelps survey, including step navigation and sending results to MyDataHelps, and is intended for modal presentation. While SurveyViewController is powerful and simple to use, make sure to read its documentation to integrate it correctly into your app.

### "My Data" tab
Implemented by `DataView` and `DataViewModel`. All of the functionality in this tab is driven by `DeviceDataQuery` and the associated `queryDeviceData` API.

- Displays a chart of the participant's health data using `DeviceDataQuery`. MyDataHelpsKit's device data APIs, combined here with SwiftUI Charts, make it easy to visualize your participant data.
    - Depending on the [sensor data configuration](https://support.mydatahelps.org/hc/en-us/categories/1500000432421-Sensor-Data) for your project and the data available for your participant, you may need to customize the query and chart in the example app. Note that it's preconfigured to use Resting Heart Rate samples from Apple Health, and the SwiftUI Preview in Xcode is also configured to show a chart of sample data.
    - The "Show All Data" button below the chart uses the same `DeviceDataQuery` parameters to display a raw list of the data associated with the chart.
    - Query APIs in MyDataHelpsKit use a paging concept to fetch any number of batches of data. But as shown with this example, when only a limited set of well-defined data is needed, the same APIs can be used to simply fetch one page and extract the results from that page as a single array.
- Shows recently-updated project-scoped device data.
    - MyDataHelpsKit uses `DeviceDataNamespace` to differentiate between project device data points and other types of sensor data.
    - Unlike other sensor data, project device data points are defined and managed entirely by your project, and you can use MyDataHelps APIs to modify this data. The example app allows adding or editing project device data using the `persistDeviceData` API.
- Displays a hierarchical browser for all other sensor data available to your project. This uses the `queryableDeviceDataTypes` set returned by the `getDataCollectionSettings` API to determine what categories of sensor data are available to the project. Selecting one of these categories in the example app performs a `DeviceDataQuery` filtered to the appropriate namespace + data type to list the appropriate device data points.
    - Use this data browser in the example app to determine the exact `namespace` and `type` values to use to construct the correct `DeviceDataQuery` for your specific use case.

### "Activity" tab
Implemented by `ActivityView` and `ActivityViewModel`.

- Displays notifications sent to the participant. Each `NotificationType` (SMS, push, email) has different content, and the `NotificationHistoryView` demonstrates various ways to handle the notification content returned by MyDataHelpsKit.
- Displays a full list of all survey answers using `SurveyAnswersQuery`. This is similar to the Tasks tab above, but the query is not constrained to a specific survey.

### "Account" tab
Implemented by `AccountView` and `AccountViewModel`.

- Uses the `getParticipantInfo` and `getProjectInfo` APIs to show information about the currently authenticated participant and the associated project. You would use these APIs in various ways in your app to configure your UI or the features available to the user.
- If [Electronic Health Record (EHR) Data collection](https://support.mydatahelps.org/hc/en-us/articles/9486061789203-Electronic-Health-Record-EHR-Data) is enabled for your project, the External Accounts view is available in the example app.
    - Displays a list of any external accounts that the participant has already connected, using the `listExternalAccounts` API.
    - Existing accounts can be refreshed or deleted using MyDataHelpsKit.
    - The "+" button shows a searchable list of all available external account providers using `ExternalAccountProvidersQuery`. Selecting a provider presents an authorization flow to the participant, and upon completion this establishes a new external account connection for that provider.

External account connection is a multi-step process that requires your project to be configured correctly in MyDataHelps Designer, and your participant-facing app to be correctly configured to handle the web-based OAuth authorization flow. See the `connectExternalAccount` documentation in MyDataHelpsKit to get started.

### Other features

Many APIs in MyDataHelpsKit follow a common _query → page of results_ pattern. The example app implements a `PagedListView`, `PagedViewModel`, and `PagedModelSource` that take advantage of this design pattern to form reusable SwiftUI view components for displaying these paged results. These views demonstrate automatic loading of additional pages, infinite scrolling, and handling empty results and errors. `PagedListView` encapsulates everything into a single full-screen list view, while smaller view components are used throughout the app to embed paged results within other views.

A common UI pattern for data fetched asynchronously—as with most of the APIs of MyDataHelpsKit—is handling three states for a given set of data: loading, successfully loaded, and failure. The example app's `AsyncCardView`, combined with `RemoteResult`, demonstrates a reusable SwiftUI component for handling this pattern.
