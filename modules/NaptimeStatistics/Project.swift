import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.NaptimeStatistics.rawValue,
    targets: [
        .makeApp(
            name: "NaptimeStatisticsApp",
            bundleIdExtension: ".NaptimeStatistics",
            deploymentTargets: .iOS("17.0"),
            sources: [
                "app/**"
            ],
            dependencies: [
                .common,
                .feature(implementation: .NaptimeStatistics),
                .feature(implementation: .DesignSystem),
            ]
        ),
        .feature(
            implementation: .NaptimeStatistics,
            dependencies: [
                .common,
                .external(name: "ComposableArchitecture"),
            ],
            resources: [
                "resources/**"
            ]
        )
    ]
)
