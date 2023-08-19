import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.Activity.rawValue,
    targets: [
        .feature(
            interface: .Activity,
            dependencies: [
                .common
            ]
        ),
        .feature(
            implementation: .Activity,
            dependencies: [
                .common,
                .feature(interface: .Activity),
                .feature(interface: .DesignSystem),
                .external(name: "ComposableArchitecture"),
            ],
            resources: [
                "resources/**"
            ]
        )
    ]
)
