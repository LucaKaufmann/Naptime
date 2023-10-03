import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.NaptimeStatistics.rawValue,
    targets: [
        .makeApp(
            name: "NaptimeStatisticsApp",
            bundleIdExtension: ".NaptimeStatistics",
            deploymentTarget: .iOS(targetVersion: "17.0", devices: [
                .iphone,
                .ipad
            ]),
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
