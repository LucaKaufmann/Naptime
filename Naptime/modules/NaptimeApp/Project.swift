import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.NaptimeApp.rawValue,
    targets: [
        .makeApp(
            name: "NaptimeApp",
            sources: [
                "src/**"
            ],
            dependencies: [
                .common,
                .feature(implementation: .Activity),
                .feature(interface: .Activity)
            ]
        )
    ]
)
