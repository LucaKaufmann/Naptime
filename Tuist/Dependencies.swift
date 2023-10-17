//
//  Dependencies.swift
//  NaptimeManifests
//
//  Created by Luca Kaufmann on 14.8.2023.
//

import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/pointfreeco/swift-composable-architecture", requirement: .upToNextMajor(from: "1.0.0")),
        .remote(url: "https://github.com/LucaKaufmann/ScalingHeaderScrollView", requirement: .branch("master")),
        .remote(url: "https://github.com/apple/swift-async-algorithms", requirement: .upToNextMajor(from: "0.1.0")),
    ],
    platforms: [.iOS, .watchOS]
)
