import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

/*
                +-------------+
                |             |
                |     App     | Contains Naptime App target and Naptime unit-test target
                |             |
         +------+-------------+-------+
         |         depends on         |
         |                            |
 +----v-----+                   +-----v-----+
 |          |                   |           |
 |   Kit    |                   |     UI    |   Two independent frameworks to share code and start modularising your app
 |          |                   |           |
 +----------+                   +-----------+

 */

// MARK: - Project
let project = Project(
    name: "Naptime",
    organizationName: "com.hotky",
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
        Target(
            name: "Naptime",
            platform: .iOS,
            product: .app,
            bundleId: "com.hotky.Naptime",
            deploymentTarget: .iOS(targetVersion: "16.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/Naptime/Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "AsyncAlgorithms"),
                .external(name: "ScalingHeaderScrollView"),
            ]
        ),
        Target(
            name: "NaptimeUI",
            platform: .iOS,
            product: .framework,
            bundleId: "com.hotky.NaptimeUI",
            deploymentTarget: .iOS(targetVersion: "16.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/NaptimeUI/Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "AsyncAlgorithms"),
                .external(name: "ScalingHeaderScrollView"),
            ]
        ),
        Target(
            name: "NaptimeKit",
            platform: .iOS,
            product: .framework,
            bundleId: "com.hotky.NaptimeKit",
            deploymentTarget: .iOS(targetVersion: "16.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/NaptimeKit/Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "AsyncAlgorithms"),
                .external(name: "ScalingHeaderScrollView"),
            ]
        ),
        Target(
            name: "NaptimeActivityFeature",
            platform: .iOS,
            product: .framework,
            bundleId: "com.hotky.NaptimeActivityFeature",
            deploymentTarget: .iOS(targetVersion: "16.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/Features/Activity/Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "AsyncAlgorithms"),
                .external(name: "ScalingHeaderScrollView"),
            ]
        ),
    ]
)
