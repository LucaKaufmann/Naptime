import ProjectDescription

private let rootPackagesName = "com.hotky.Naptime"

private func makeBundleID(with addition: String) -> String {
    (rootPackagesName + addition)
}

public extension Target {
    static func makeApp(
        name: String,
        bundleIdExtension: String = "",
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        sources: ProjectDescription.SourceFilesList,
        resources: ProjectDescription.ResourceFileElements? = [],
        dependencies: [ProjectDescription.TargetDependency]
    ) -> Target {
        Target.target(
            name: name,
            destinations: destinations,
            product: .app,
            bundleId: makeBundleID(with: ""+bundleIdExtension),
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: infoPlistExtension),
            sources: sources,
            resources: resources,
            entitlements: .file(path: .relativeToRoot("Naptime.entitlements")),
            dependencies: dependencies
        )
    }

    static func makeExtension(
        name: String,
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        infoPlist: InfoPlist? = nil,
        sources: ProjectDescription.SourceFilesList,
        resources: ProjectDescription.ResourceFileElements? = [],
        dependencies: [ProjectDescription.TargetDependency] = []
    ) -> Target {
        Target.target(
            name: name,
            destinations: destinations,
            product: .appExtension,
            bundleId: makeBundleID(with: "." + name),
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: .file(path: .relativeToRoot("Naptime.entitlements")),
            dependencies: dependencies
        )
    }

    static func makeFramework(
        name: String,
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        sources: ProjectDescription.SourceFilesList,
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = [],
        coreDataModels: [CoreDataModel]
    ) -> Target {
        Target.target(
            name: name,
            destinations: destinations,
            product: defaultPackageType,
            bundleId: makeBundleID(with: name + ".framework"),
            deploymentTargets: deploymentTargets,
            sources: sources,
            resources: resources,
            entitlements: .file(path: .relativeToRoot("Naptime.entitlements")),
            dependencies: dependencies,
            coreDataModels: coreDataModels
        )
    }

    private static func feature(
        implementation featureName: String,
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = [],
        coreDataModels: [CoreDataModel]
    ) -> Target {
        .makeFramework(
            name: featureName,
            destinations: destinations,
            deploymentTargets: deploymentTargets,
            sources: [ "src/**" ],
            dependencies: dependencies,
            resources: resources,
            coreDataModels: coreDataModels
        )
    }

    private static func feature(
        interface featureName: String,
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        dependencies: [ProjectDescription.TargetDependency] = [],
        resources: ProjectDescription.ResourceFileElements? = []
    ) -> Target {
        .makeFramework(
            name: featureName + "Interface",
            destinations: destinations,
            deploymentTargets: deploymentTargets,
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
                             destinations: Destinations = .iOS,
                             deploymentTargets: DeploymentTargets = .iOS("17.0"),
                             infoPlist: InfoPlist? = nil,
                             dependencies: [ProjectDescription.TargetDependency] = []) -> Target {
        .makeExtension(name: featureName.rawValue,
                       destinations: destinations,
                       deploymentTargets: deploymentTargets,
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

    static func makeUnitTests(
        name: String,
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        sources: ProjectDescription.SourceFilesList,
        dependencies: [ProjectDescription.TargetDependency] = []
    ) -> Target {
        Target.target(
            name: name,
            destinations: destinations,
            product: .unitTests,
            bundleId: makeBundleID(with: ".\(name)"),
            deploymentTargets: deploymentTargets,
            sources: sources,
            dependencies: dependencies
        )
    }

    static func featureTests(
        for featureName: Feature,
        dependencies: [ProjectDescription.TargetDependency] = []
    ) -> Target {
        .makeUnitTests(
            name: "\(featureName.rawValue)Tests",
            sources: ["tests/**"],
            dependencies: [.target(name: featureName.rawValue)] + dependencies
        )
    }
}
