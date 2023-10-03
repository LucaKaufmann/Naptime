import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.Activity.rawValue,
    targets: [
        .makeApp(
            name: "NaptimeActivityApp",
            bundleIdExtension: ".NaptimeActivity",
            deploymentTarget: .iOS(targetVersion: "17.0", devices: [
                .iphone,
                .ipad
            ]),
            sources: [
                "app/**"
            ],
            dependencies: [
                .common,
                .feature(implementation: .Activity),
                .feature(implementation: .DesignSystem),
            ]
        ),
        .feature(
            implementation: .Activity,
            dependencies: [
                .common,
                .feature(implementation: .DesignSystem),
                .feature(implementation: .NaptimeSettings),
                .feature(implementation: .NaptimeStatistics),
                .external(name: "ComposableArchitecture"),
            ],
            resources: [
                "resources/**"
            ]
        )
    ]
)
