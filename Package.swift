// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [
       	.macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "Network", targets: ["Network"])
    ],
    dependencies: [
        .package(url: "https://github.com/DingSoung/Extension", .branch("master"))
    ],
    targets: [
        .target(
            name: "Network",
            dependencies: ["Extension"],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [
        .version("5")
    ]
)
