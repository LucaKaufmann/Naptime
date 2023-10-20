import ProjectDescription

private let rootPackagesName = "com.hotky.Naptime"

private func makeBundleID(with addition: String) -> String {
    (rootPackagesName + addition)
}

public extension Target {
    static func makeApp(
        name: String,
        platform: Platform = .iOS,
        bundleIdExtension: String = "",
        deploymentTarget: ProjectDescription.DeploymentTarget?,
        sources: ProjectDescription.SourceFilesList,
        resources: ProjectDescription.ResourceFileElements? = [],
        dependencies: [ProjectDescription.TargetDependency]
    ) -> Target {
        Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: makeBundleID(with: ""+bundleIdExtension),
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: infoPlistExtension),
            sources: sources,
            resources: resources,
            entitlements: .file(path: .relativeToRoot("Naptime.entitlements")),
            dependencies: dependencies
        )
    }
    
    static func makeWatchApp() -> Target {
        Target(name: "WatchApp",
               platform: .watchOS,
               product: .app,
               bundleId: "com.hotky.Naptime.WatchApp",
               infoPlist: .extendingDefault(with: infoPlistExtension.merging([
                "WKApplication": true,
                "WKCompanionAppBundleIdentifier": "com.hotky.Naptime"
            ]) {
                    (current, _) in current
               }),
               sources: "NaptimeWatchApp/src/**",
               resources: "NaptimeWatchApp/resources/**",
               dependencies: [
                .feature(implementation: .NaptimeKitWatchOS),
                .feature(implementation: .ActivityWatchOS)
               ])
    }
    
    
    static func makeExtension(
        name: String,
        platform: Platform = .iOS,
        deploymentTarget: ProjectDescription.DeploymentTarget?,
        infoPlist: InfoPlist? = nil,
        sources: ProjectDescription.SourceFilesList,
        resources: ProjectDescription.ResourceFileElements? = [],
        dependencies: [ProjectDescription.TargetDependency] = []
    ) -> Target {
        Target(
            name: name,
            platform: platform,
            product: .appExtension,
            bundleId: makeBundleID(with: "." + name),
            deploymentTarget: deploymentTarget,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: .file(path: .relativeToRoot("Naptime.entitlements")),
            dependencies: dependencies
        )
    }

    static func makeFramework(
        name: String,
        deploymentTarget: ProjectDescription.DeploymentTarget?,
        platform: Platform = .iOS,
        sources: ProjectDescription.SourceFilesList,
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = [],
        coreDataModels: [CoreDataModel]
    ) -> Target {
        Target(
            name: name,
            platform: platform,
            product: defaultPackageType,
            bundleId: makeBundleID(with: name + ".framework"),
            deploymentTarget: deploymentTarget,
            sources: sources,
            resources: resources,
            entitlements: .file(path: .relativeToRoot("Naptime.entitlements")),
            dependencies: dependencies,
            coreDataModels: coreDataModels
        )
    }

    private static func feature(
        implementation featureName: String,
        deploymentTarget: ProjectDescription.DeploymentTarget? = .iOS(targetVersion: "17.0", devices: .iphone),
        platform: Platform = .iOS,
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = [],
        coreDataModels: [CoreDataModel]
    ) -> Target {
        .makeFramework(
            name: featureName,
            deploymentTarget: deploymentTarget,
            platform: platform,
            sources: [ "src/**" ],
            dependencies: dependencies,
            resources: resources,
            coreDataModels: coreDataModels
        )
    }

    private static func feature(
        interface featureName: String,
        deploymentTarget: ProjectDescription.DeploymentTarget? = .iOS(targetVersion: "17.0", devices: .iphone),
        platform: Platform = .iOS,
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = []
    ) -> Target {
        .makeFramework(
            name: featureName + "Interface",
            deploymentTarget: deploymentTarget,
            platform: platform,
            sources: [ "interface/**" ],
            dependencies: dependencies,
            resources: resources,
            coreDataModels: []
        )
    }

    static func feature(
        implementation featureName: Feature,
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = [],
        coreDataModels: [CoreDataModel] = []
    ) -> Target {
        .feature(
            implementation: featureName.rawValue,
            deploymentTarget: featureName.rawValue.contains("WatchOS") ? .watchOS(targetVersion: "10") : .iOS(targetVersion: "17.0", devices: .iphone),
            platform: featureName.rawValue.contains("WatchOS") ? .watchOS : .iOS,
            dependencies: dependencies,
            resources: resources,
            coreDataModels: coreDataModels
        )
    }
    
    static func featureWatch(
        implementation featureName: Feature,
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = [],
        coreDataModels: [CoreDataModel] = []
    ) -> Target {
        .feature(
            implementation: featureName.rawValue,
            deploymentTarget: .watchOS(targetVersion: "10.0"),
            platform: featureName.rawValue.contains("WatchOS") ? .watchOS : .iOS,
            dependencies: dependencies,
            resources: resources,
            coreDataModels: coreDataModels
        )
    }

    static func feature(
        interface featureName: Feature,
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = []
    ) -> Target {
        .feature(
            interface: featureName.rawValue,
            dependencies: dependencies,
            resources: resources
        )
    }
    
    static func appExtension(implementation featureName: Feature,
                             deploymentTarget: ProjectDescription.DeploymentTarget? = .iOS(targetVersion: "17.0", devices: .iphone),
                             infoPlist: InfoPlist? = nil,
                             dependencies: [ProjectDescription.TargetDependency] = []) -> Target {
        .makeExtension(name: featureName.rawValue,
                       deploymentTarget: deploymentTarget,
                       infoPlist: infoPlist,
                       sources: [
                           "\(featureName.rawValue)/src/**"
                       ],
                       resources: [
                            "\(featureName.rawValue)/resources/**"
                       ],
                       dependencies: [
                           .common,
                           .feature(implementation: .DesignSystem),
                       ])
    }
}
