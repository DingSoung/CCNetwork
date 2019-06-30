// swift-tools-version:5.0.0

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "Network", targets: ["Network"])
    ],
    targets: [
        .target(name: "Network", dependencies: [], path: "Sources")
    ],
    swiftLanguageVersions: [
        .version("5.0.0")
    ]
)
