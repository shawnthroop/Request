// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Request",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "Request",
            targets: ["Request"]),
    ],
    targets: [
        .target(
            name: "Request"
        ),
        .testTarget(
            name: "RequestTests",
            dependencies: ["Request"]),
    ]
)
