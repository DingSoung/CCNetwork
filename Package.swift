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
    dependencies: [
        .package(url: "https://github.com/DingSoung/Extension", from: "0.8.9")
    ],
    targets: [
        .target(name: "Network", path: "Sources")
    ],
    swiftLanguageVersions: [
        .version("5.0.0")
    ]
)
