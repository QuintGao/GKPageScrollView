// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GKPageScrollViewSwift",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "GKPageScrollViewSwift",
            type: .static,
            targets: ["GKPageScrollViewSwift"])
    ],
    targets: [
        .target(
            name: "GKPageScrollViewSwift",
            path: "Sources/GKPageScrollViewSwift"
        )
    ]
)
