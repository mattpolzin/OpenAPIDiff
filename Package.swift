// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "OpenAPIDiff",
    products: [
        .library(name: "OpenAPIDiff", targets: ["OpenAPIDiff"]),
        .executable(name: "openapi-diff", targets: ["openapi-diff"])
    ],
    dependencies: [
        .package(url: "https://github.com/mattpolzin/OpenAPIKit.git", .branch("release/3_0")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/fabianfett/pure-swift-json.git", .upToNextMinor(from: "0.4.0"))
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
                .product(name: "OpenAPIKitCompat", package: "OpenAPIKit"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "PureSwiftJSON", package: "pure-swift-json"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
