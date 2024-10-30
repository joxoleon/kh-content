// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ContentChef",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "ContentChef", targets: ["ContentChef"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ContentChef",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Yams"
            ]
        ),
        .testTarget(
            name: "ContentChefTests",
            dependencies: ["ContentChef"],
            path: "Tests/ContentChefTests" // Explicitly specify the path to the test target
        ),
    ]
)
