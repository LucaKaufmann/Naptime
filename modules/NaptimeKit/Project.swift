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
                CoreDataModel.coreDataModel("src/NapTimeData/Naptime.xcdatamodeld")
            ]
        ),
        .featureTests(
            for: .NaptimeKit,
            dependencies: [
                .external(name: "ComposableArchitecture"),
            ]
        )
    ]
)
