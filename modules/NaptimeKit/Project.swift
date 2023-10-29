import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.NaptimeKit.rawValue,
    targets: [
        .feature(
            implementation: .NaptimeKit,
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "AsyncAlgorithms"),
            ],
            resources: [
                "resources/**"
            ],
            coreDataModels: [
                .init("src/NapTimeData/Naptime.xcdatamodeld")
            ]
        ),
        .featureWatch(
            implementation: .NaptimeKitWatchOS,
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "AsyncAlgorithms"),
            ],
            resources: [
                "resources/**"
            ],
            coreDataModels: [
                .init("src/NapTimeData/Naptime.xcdatamodeld")
            ]
        )
    ]
)
