// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MyDataHelpsKit",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_15)
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
            path: "MyDataHelpsKitTests"
        )
    ]
)
