// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "OpenAPIDiff",
    products: [
        .library(name: "OpenAPIDiff", targets: ["OpenAPIDiff"]),
        .executable(name: "openapi-diff", targets: ["openapi-diff"])
    ],
    dependencies: [
        .package(url: "https://github.com/mattpolzin/OpenAPIKit", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.2.0"))
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
            dependencies: [
                "OpenAPIDiff",
                "Yams",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
