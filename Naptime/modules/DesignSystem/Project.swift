import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.DesignSystem.rawValue,
    targets: [
        .feature(
            interface: .DesignSystem,
            dependencies: [
                .common
            ]
        ),
        .feature(
            implementation: .DesignSystem,
            dependencies: [
                .common,
                .feature(interface: .DesignSystem),
            ],
            resources: [
                "resources/**"
            ]
        )
    ]
)
