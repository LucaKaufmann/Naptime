import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.DesignSystem.rawValue,
    targets: [
        .feature(
            interface: .DesignSystem
        ),
        .feature(
            implementation: .DesignSystem,
            dependencies: [],
            resources: [
                "resources/**"
            ]
        ),
        .featureWatch(
            implementation: .DesignSystemWatchOS,
            dependencies: [],
            resources: [
                "resources/**"
            ]
        )
    ]
)
