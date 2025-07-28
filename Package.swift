// swift-tools-version: 6.1.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TuckerNetworking",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "TuckerNetworking",
            targets: ["TuckerNetworking"]
        ),
    ],
    targets: [
        .target(
            name: "TuckerNetworking"
        ),
        .testTarget(
            name: "TuckerNetworkingTests",
            dependencies: ["TuckerNetworking"]
        ),
    ]
)
