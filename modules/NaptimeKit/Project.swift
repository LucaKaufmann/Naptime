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
            coreDataModels: [
                .init("src/NapTimeData/Naptime.xcdatamodeld")
            ]
        )
    ]
)
