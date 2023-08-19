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
        dependencies: [ProjectDescription.TargetDependency]
    ) -> Target {
        Target(
            name: name,
            platform: .iOS,
            product: .app,
            bundleId: makeBundleID(with: "app"),
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: infoPlistExtension),
            sources: sources,
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
}
