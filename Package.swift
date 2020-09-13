// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GKPageScrollView",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "GKPageScrollView",
            type: .static,
            targets: ["GKPageScrollView"])
    ],
    targets: [
        .target(
            name: "GKPageScrollView",
            path: "GKPageScrollView/swift"
        )
    ]
)
