//
//  ActivityDependencies.swift
//  Activity
//
//  Created by Luca Kaufmann on 19.8.2023.
//

import ComposableArchitecture
#if os(macOS) || os(iOS) || os(tvOS)
import NaptimeKit
#elseif os(watchOS)
import NaptimeKitWatchOS
#endif

private enum ActivityServiceKey: DependencyKey {
    static let liveValue = ActivityService(persistence: PersistenceController.shared)
//        static let liveValue = ActivityService(persistence: PersistenceController.preview)
    static let testValue = ActivityService(persistence: PersistenceController.preview)
    static let previewValue = ActivityService(persistence: PersistenceController.shared)
    
}

public extension DependencyValues {
    var activityService: ActivityService {
        get { self[ActivityServiceKey.self] }
        set { self[ActivityServiceKey.self] = newValue }
    }
}


#if canImport(ActivityKit)
private enum LiveActivityServiceKey: DependencyKey {
    static let liveValue = LiveActivityService()
}

extension DependencyValues {
    var liveActivityService: LiveActivityService {
        get { self[LiveActivityServiceKey.self] }
        set { self[LiveActivityServiceKey.self] = newValue }
    }
}
#endif
