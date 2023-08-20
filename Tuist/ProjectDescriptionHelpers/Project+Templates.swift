import ProjectDescription

private let rootPackagesName = "com.hotky.naptime"

private func makeBundleID(with addition: String) -> String {
    (rootPackagesName + addition).lowercased()
}

public extension Target {
    static func makeApp(
        name: String,
        deploymentTarget: ProjectDescription.DeploymentTarget?,
        sources: ProjectDescription.SourceFilesList,
        resources: ProjectDescription.ResourceFileElements? = [],
        dependencies: [ProjectDescription.TargetDependency]
    ) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: makeBundleID(with: ""),
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: infoPlistExtension),
            sources: sources,
            resources: resources,
            entitlements: .relativeToRoot("Naptime.entitlements"),
            dependencies: dependencies
        )
    }
    
    static func makeExtension(
        name: String,
        deploymentTarget: ProjectDescription.DeploymentTarget?,
        infoPlist: InfoPlist? = nil,
        sources: ProjectDescription.SourceFilesList,
        resources: ProjectDescription.ResourceFileElements? = [],
        dependencies: [ProjectDescription.TargetDependency] = []
    ) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: .appExtension,
            bundleId: makeBundleID(with: "." + name + ".extension"),
            deploymentTarget: deploymentTarget,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: .relativeToRoot("Naptime.entitlements"),
            dependencies: dependencies
        )
    }

    static func makeFramework(
        name: String,
        deploymentTarget: ProjectDescription.DeploymentTarget?,
        sources: ProjectDescription.SourceFilesList,
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = [],
        coreDataModels: [CoreDataModel]
    ) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: defaultPackageType,
            bundleId: makeBundleID(with: name + ".framework"),
            deploymentTarget: deploymentTarget,
            sources: sources,
            resources: resources,
            entitlements: .relativeToRoot("Naptime.entitlements"),
            dependencies: dependencies,
            coreDataModels: coreDataModels
        )
    }

    private static func feature(
        implementation featureName: String,
        deploymentTarget: ProjectDescription.DeploymentTarget? = .iOS(targetVersion: "16.0", devices: .iphone),
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = [],
        coreDataModels: [CoreDataModel]
    ) -> Target {
        .makeFramework(
            name: featureName,
            deploymentTarget: deploymentTarget,
            sources: [ "src/**" ],
            dependencies: dependencies,
            resources: resources,
            coreDataModels: coreDataModels
        )
    }

    private static func feature(
        interface featureName: String,
        deploymentTarget: ProjectDescription.DeploymentTarget? = .iOS(targetVersion: "16.0", devices: .iphone),
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = []
    ) -> Target {
        .makeFramework(
            name: featureName + "Interface",
            deploymentTarget: deploymentTarget,
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
                             deploymentTarget: ProjectDescription.DeploymentTarget? = .iOS(targetVersion: "16.0", devices: .iphone),
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
