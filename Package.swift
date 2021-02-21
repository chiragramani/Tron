// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tron",
    defaultLocalization: "en",
    platforms: [.macOS(.v10_13)],
    dependencies: [
        .package(name: "XcodeProj",
                 url: "https://github.com/tuist/xcodeproj.git",
                 .upToNextMajor(from: "7.18.0")),
        .package(url: "https://github.com/apple/swift-argument-parser",
                 .upToNextMinor(from: "0.3.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "Tron",
                dependencies: ["TronCore"]),
        .target(
            name: "TronCore",
            dependencies:["XcodeProj",
                          .product(name: "ArgumentParser",
                                   package: "swift-argument-parser")],
            resources: [.copy("Resources/iOS")]),
        .testTarget(
            name: "TronCoreTests",
            dependencies: ["TronCore"]),
    ]
)
