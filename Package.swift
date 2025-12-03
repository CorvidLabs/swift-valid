// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-valid",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Valid",
            targets: ["Valid"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "Valid",
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "ValidTests",
            dependencies: ["Valid"]
        )
    ],
    swiftLanguageModes: [.v6]
)
