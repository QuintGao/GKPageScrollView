// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GKPageScrollView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "GKPageScrollView",
            targets: ["GKPageScrollView"]
        ),
        .library(
            name: "GKPageScrollViewSwift",
            targets: ["GKPageScrollViewSwift"]
        ),
        .library(
            name: "GKPageSmoothView",
            targets: ["GKPageSmoothView"]
        ),
        .library(
            name: "GKPageSmoothViewSwift",
            targets: ["GKPageSmoothViewSwift"]
        )
    ],
    targets: [
        .target(
            name: "GKPageScrollView",
            dependencies: [],
            path: "Sources",
            sources: ["GKPageScrollView"]
        ),
        .target(
            name: "GKPageScrollViewSwift",
            dependencies: [],
            path: "Sources",
            sources: ["GKPageScrollViewSwift"]
        ),
        .target(
            name: "GKPageSmoothView",
            dependencies: [],
            path: "Sources",
            sources: ["GKPageSmoothView"]
        ),
        .target(
            name: "GKPageSmoothViewSwift",
            dependencies: [],
            path: "Sources",
            sources: ["GKPageSmoothViewSwift"]
        )
    ]
)
