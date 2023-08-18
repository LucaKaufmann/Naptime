import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: Feature.NaptimeKit.rawValue,
    targets: [
        .feature(
            implementation: .NaptimeKit
        )
    ]
)
