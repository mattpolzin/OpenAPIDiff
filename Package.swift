// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenAPIDiff",
    products: [
        .library(name: "OpenAPIDiff", targets: ["OpenAPIDiff"]),
        .executable(name: "openapi-diff", targets: ["openapi-diff"])
    ],
    dependencies: [
        .package(url: "https://github.com/mattpolzin/OpenAPIKit.git", .upToNextMinor(from: "0.29.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.0.2"))
    ],
    targets: [
        .target(
            name: "OpenAPIDiff",
            dependencies: ["OpenAPIKit", "Yams"]),
        .testTarget(
            name: "OpenAPIDiffTests",
            dependencies: ["OpenAPIDiff"]),
        .target(
            name: "openapi-diff",
            dependencies: ["OpenAPIDiff", "Yams", "ArgumentParser"])
    ]
)
