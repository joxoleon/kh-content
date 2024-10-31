// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "KHContentSource",
    platforms: [
        .macOS(.v10_15), 
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "KHContentSource", 
            targets: ["KHContentSource"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "KHContentSource",
            dependencies: [
                "Yams",
            ]
        ),
        .testTarget(
            name: "KHContentSourceTests",
            dependencies: ["KHContentSource"],
            path: "Tests/KHContentSourceTests"
        ),
    ]
)
