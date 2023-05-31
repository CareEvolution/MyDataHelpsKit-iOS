// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "MyDataHelpsKit",
    platforms: [
        .iOS("13.6"),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MyDataHelpsKit",
            targets: ["MyDataHelpsKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MyDataHelpsKit",
            path: "MyDataHelpsKit",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "MyDataHelpsKitTests",
            dependencies: ["MyDataHelpsKit"],
            path: "MyDataHelpsKitTests",
            exclude: ["Info.plist"]
        )
    ]
)
