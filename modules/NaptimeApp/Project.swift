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
            name: "Naptime",
            deploymentTarget: .iOS(targetVersion: "17.0", devices: [
                .iphone,
                .ipad
            ]),
            sources: [
                "src/**"
            ],
            resources: [
                "resources/**"
            ],
            dependencies: [
                .common,
                .feature(implementation: .Activity),
                .feature(implementation: .DesignSystem),
                .target(name: Feature.NaptimeWidget.rawValue),
                .external(name: "ComposableArchitecture"),
                .external(name: "ScalingHeaderScrollView"),
            ]
        ),
        .makeWatchApp(),
        .appExtension(implementation: .NaptimeWidget,
                      deploymentTarget: .iOS(targetVersion: "17.0", devices: .iphone),
                      infoPlist: .extendingDefault(with: [
                        "CFBundleDisplayName": "Naptime Widget",
                        "NSExtension": [
                            "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
                        ]
                      ]),
                      dependencies: [
                        .common,
                        .feature(implementation: .DesignSystem),
                      ]),
//        .appExtension(implementation: .NaptimeWatchApp,
//                      deploymentTarget: .watchOS(targetVersion: "10.0"),
//                      infoPlist: .extendingDefault(with: [
//                        "CFBundleDisplayName": "Naptime"
//                      ]),
//                      dependencies: [
//                        .common,
//                        .feature(implementation: .DesignSystem),
//                      ])
//            .makeApp(
//                name: "NaptimeWatch",
//                platform: .watchOS,
//                deploymentTarget: .watchOS(targetVersion: "10.0"),
//                sources: [
//                    "src/**"
//                ],
//                resources: [
//                    "resources/**"
//                ],
//                dependencies: [
////                    .common,
////                    .feature(implementation: .Activity),
////                    .feature(implementation: .DesignSystem),
////                    .external(name: "ComposableArchitecture"),
//                ]
//            ),
    ]
)
