import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.NaptimeWidget.rawValue,
    targets: [
        .feature(
            interface: .NaptimeWidget,
            dependencies: [
                .common
            ]
        ),
        .appExtension(implementation: .NaptimeWidget,
                      deploymentTarget: .iOS(targetVersion: "16.2", devices: .iphone),
                      infoPlist: .extendingDefault(with: [
                        "NSExtension": [
                            "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
                        ]
                      ]),
                      dependencies: [
                        .common,
                        .feature(implementation: .DesignSystem),
                      ])
    ]
)
