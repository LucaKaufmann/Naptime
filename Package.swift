// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture": .framework,
        "ScalingHeaderScrollView": .framework,
        "AsyncAlgorithms": .framework,
    ]
)
#endif

let package = Package(
    name: "Naptime",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/LucaKaufmann/ScalingHeaderScrollView", branch: "master"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),
    ]
)
