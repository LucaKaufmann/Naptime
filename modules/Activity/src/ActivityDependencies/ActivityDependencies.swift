//
//  ActivityDependencies.swift
//  Activity
//
//  Created by Luca Kaufmann on 19.8.2023.
//

import ComposableArchitecture
import NaptimeKit

private enum ActivityServiceKey: DependencyKey {
    static let liveValue = ActivityService(persistence: PersistenceController.shared)
//        static let liveValue = ActivityService(persistence: PersistenceController.preview)
    static let testValue = ActivityService(persistence: PersistenceController.preview)
    static let previewValue = ActivityService(persistence: PersistenceController.preview)
    
}

public extension DependencyValues {
    var activityService: ActivityService {
        get { self[ActivityServiceKey.self] }
        set { self[ActivityServiceKey.self] = newValue }
    }
}

private enum LiveActivityServiceKey: DependencyKey {
    static let liveValue = LiveActivityService()
}

extension DependencyValues {
    var liveActivityService: LiveActivityService {
        get { self[LiveActivityServiceKey.self] }
        set { self[LiveActivityServiceKey.self] = newValue }
    }
}
