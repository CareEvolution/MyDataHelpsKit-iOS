# MyDataHelpsKit

An SDK to integrate [MyDataHelps™](https://careevolution.com/mydatahelps/) with your apps to develop your own participant experiences.

See [GitHub releases][releases] for release notes.

[© CareEvolution, LLC](https://developer.mydatahelps.org)

## Getting started

Consult the online documentation's [overview](https://developer.mydatahelps.org/ios/) and [Getting Started](https://developer.mydatahelps.org/ios/getting_started.html) pages for installation instructions and guides to using MyDataHelpsKit.

## Installation

### Requirements

MyDataHelpsKit is a Cocoa Touch framework, linked to your app as a static library. It's built with the latest Xcode, Swift, and iOS SDK versions, and supports iOS 13.6 and above. MyDataHelpsKit is self-contained; there are no dependencies on other frameworks or libraries, and requires no Apple frameworks other than Foundation (a few optional features use UIKit or SwiftUI).

Based on your preferred installation process or dependency manager, choose from the below options to integrate MyDataHelpsKit.

### Swift Package Manager

Add `MyDataHelpsKit-iOS` as a Swift Package dependency to your project. For more information, see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/main/Documentation).

In your Xcode workspace, go to File > Swift Packages > Add Package Dependency and enter `https://github.com/CareEvolution/MyDataHelpsKit-iOS`. Or edit your project's Package.swift file:

```swift
.package(url: "https://github.com/CareEvolution/MyDataHelpsKit-iOS", from: "2.0.0")
```

### Carthage

Use the [standard Carthage workflow](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for static frameworks:

1. Add `github "CareEvolution/MyDataHelpsKit-iOS"` to your Cartfile.
2. Run `carthage update --use-xcframeworks`
3. Open your app target's General settings tab in Xcode. In Finder, go to the `Carthage/Build` folder, and drag and drop `MyDataHelpsKit.xcframework` from the `Carthage/Build` folder into the "Frameworks, Libraries, and Embedded Content" section in Xcode.

To update MyDataHelpsKit to a newer version, run `carthage update --use-xcframeworks`, optionally appending MyDataHelpsKit-iOS to the command to only update this SDK and not other Carthage dependencies.

### Cocoapods

Use the [standard Cocoapods workflow](https://guides.cocoapods.org/using/using-cocoapods.html):

1. Create a Podfile for your project using `pod init` if needed.
2. Add `pod 'MyDataHelpsKit'` to your Podfile.
3. Run `pod install`

To update MyDataHelpsKit to a newer version, run `pod update`, optionally appending MyDataHelpsKit to the command to only update this SDK and not other Cocoapods dependencies.

### Manual integration

1. Download and unzip the [latest release][releases] from GitHub.
2. From Finder, drag `MyDataHelpsKit.xcodeproj`  into your app's Xcode workspace.
3. Open your app target's General settings tab in Xcode. In the project navigator pane, expand MyDataHelpsKit.xcodeproj > Products and drag MyDataHelpsKit.framework into the "Frameworks, Libraries, and Embedded Content" section.

To update to a newer version of MyDataHelpsKit, download and unzip the [latest release][releases], and then delete and replace the existing MyDataHelpsKit folder structure in your workspace.

## Next Steps

Consult the [programming guide](https://developer.mydatahelps.org/ios/programming_guide.html) to get the most out of MyDataHelpsKit. This repository includes an [example app](https://github.com/CareEvolution/MyDataHelpsKit-iOS/tree/main/example) that you can immediately build and run to get familiar with the features and usage of MyDataHelpsKit within the context of your MyDataHelps project.

Browse the [Features and User Experiences](https://developer.mydatahelps.org/ios/#features) topics to guide your implementation of specific use cases. Finally, [complete SDK reference](https://developer.mydatahelps.org/ios/reference/) is available online or via integrated Xcode symbol documentation.

[releases]: https://github.com/CareEvolution/MyDataHelpsKit-iOS/releases
