import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.NaptimeSettings.rawValue,
    targets: [
        .makeApp(
            name: "NaptimeSettingsApp",
            bundleIdExtension: ".NaptimeSettings",
            deploymentTarget: .iOS(targetVersion: "16.0", devices: [
                .iphone,
                .ipad
            ]),
            sources: [
                "app/**"
            ],
            dependencies: [
                .common,
                .feature(implementation: .NaptimeSettings),
                .feature(implementation: .DesignSystem),
            ]
        ),
        .feature(
            implementation: .NaptimeSettings,
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
