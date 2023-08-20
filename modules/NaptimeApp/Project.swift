import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.NaptimeApp.rawValue,
    settings: .settings(configurations: [
        .debug(name: "Debug",
               settings: [
                "CODE_SIGN_STYLE": "Automatic",
                "CODE_SIGN_IDENTITY": "iOS Development",
                "DEVELOPMENT_TEAM": "6Y9C574C9M"
               ]),
        .release(
            name: "Release",
            settings: [
                "CODE_SIGN_STYLE": "Automatic",
                "CODE_SIGN_IDENTITY": "iOS Distribution",
                "DEVELOPMENT_TEAM": "6Y9C574C9M"
            ]
        )
    ]),
    targets: [
        .makeApp(
            name: "NaptimeApp",
            deploymentTarget: .iOS(targetVersion: "16.0", devices: .iphone),
            sources: [
                "src/**"
            ],
            dependencies: [
                .common,
                .feature(implementation: .Activity),
                .feature(implementation: .DesignSystem),
                .external(name: "ComposableArchitecture"),
                .external(name: "ScalingHeaderScrollView"),
            ]
        )
    ]
)
