# MyDataHelpsKit

An SDK to integrate RKStudio™ with your apps to develop your own participant experiences.

[© CareEvolution, LLC](https://developer.rkstudio.careevolution.com)

## Getting started

1. Add MyDataHelpsKit to your Xcode workspace. See the [installation](#installation) section below for details
2. Create a `MyDataHelpsClient` object for communication with RKStudio/MyDataHelps. This object can be retained for the lifetime of your app
3. Obtain an access token for the authorized MyDataHelps participant. Note that your app is responsible for renewing the access token when it expires
4. Create a `ParticipantSession` using the access token. This is the primary interface for interacting with MyDataHelps. It can be retained for as long as the participant's acess token is valid; create a new `ParticipantSession` when you renew the access token or when a different participant logs in
5. Use `ParticipantSession` functions to perform MyDataHelps operations and requests for the participant

See [online documentation](https://developer.rkstudio.careevolution.com) or integrated Xcode symbol documentation for details about specfic operations and model types.

Example:

```swift
import MyDataHelpsKit
// Get a token for an authenticated MyDataHelps user within your app
let tokenString = getAccessToken()
// Initialize a MyDataHelpsKit client and session using the access token
let client = MyDataHelpsClient()
let session = ParticipantSession(client: client, accessToken: .init(token: tokenString))
// Example of using MyDataHelpsKit functionality
session.getParticipantInfo { result in
    switch result {
    case let .success(model):
        print("First Name: \(model.firstName ?? "(none)")")
        print("Last Name: \(model.lastName ?? "(none)")")
    case let .failure(error):
        print(error)
    }
}
```

For a complete sample app, see the [`example`](https://github.com/CareEvolution/MyDataHelpsKit-iOS/tree/main/example) subdirectory.

## Installation

### Requirements

MyDataHelpsKit is a Cocoa Touch framework, linked to your app as a static library. It's built with the latest Xcode, Swift, and iOS SDK versions. It supports iOS 11 and above. MyDataHelpsKit is self-contained; there are no dependencies on other frameworks or libraries, and requires no Apple frameworks other than Foundation.

Based on your preferred installation process or dependency manager, choose from the below options to integrate MyDataHelpsKit.

### Swift Package Manager

Add MyDataHelpsKit as a dependency to your Package.swift file. For more information, see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```swift
.package(url: "https://github.com/CareEvolution/MyDataHelpsKit-iOS", from: "1.0.0")
```

Or in your Xcode project, go to File > Swift Packages > Add Package Dependency and enter `https://github.com/CareEvolution/MyDataHelpsKit-iOS`.

### Carthage

Use the [standard Carthage workflow](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for static frameworks:

1. Add `github "CareEvolution/MyDataHelpsKit-iOS"` to your Cartfile
2. Run `carthage update --use-xcframeworks`
3. Open your app target's General settings tab in Xcode. In Finder, go to the `Carthage/Build` folder, and drag and drop `MyDataHelpsKit.xcframework` from the `Carthage/Build` folder into the "Frameworks, Libraries, and Embedded Content" section in Xcode

### Manual integration

1. Download and unzip the [latest release](https://github.com/CareEvolution/MyDataHelpsKit-iOS/releases)
2. From Finder, drag `MyDataHelpsKit.xcodeproj`  into your app's Xcode workspace
3. Open your app target's General settings tab in Xcode. In the project navigator pane, expand MyDataHelpsKit.xcodeproj > Products and drag MyDataHelpsKit.framework into the "Frameworks, Libraries, and Embedded Content" section 
