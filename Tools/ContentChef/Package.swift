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
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "ContentChef",
            dependencies: ["Yams"]
        ),
        .testTarget(
            name: "ContentChefTests",
            dependencies: ["ContentChef"]
        ),
    ]
)
