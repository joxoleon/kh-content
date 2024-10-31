// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "KHContentChef",
    platforms: [
        .macOS(.v10_15), 
    ],
    products: [
        .executable(
            name: "KHContentChef",
            targets: ["KHContentChef"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "KHContentChef",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Yams"
            ]
        ),
        .testTarget(
            name: "KHContentChefTests",
            dependencies: ["KHContentChef"]
        ),
    ]
)
