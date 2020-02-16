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
        .package(url: "https://github.com/mattpolzin/OpenAPIKit.git", .upToNextMinor(from: "0.17.0")),
        .package(url: "https://github.com/mattpolzin/OrderedDictionary.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/mattpolzin/Poly.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "OpenAPIDiff",
            dependencies: ["OpenAPIKit", "OrderedDictionary", "Poly", "Yams"]),
        .testTarget(
            name: "OpenAPIDiffTests",
            dependencies: ["OpenAPIDiff"]),
        .target(
            name: "openapi-diff",
            dependencies: ["OpenAPIDiff", "Yams"])
    ]
)
