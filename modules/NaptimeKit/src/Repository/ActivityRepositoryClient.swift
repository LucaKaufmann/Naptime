//
//  ActivityRepositoryClient.swift
//  NaptimeKit
//
//  Created by Claude on 2024.
//

import ComposableArchitecture
import Foundation

/// TCA dependency client for activity repository operations
///
/// This client provides a struct-based interface for the repository,
/// which integrates with TCA's dependency injection system.
public struct ActivityRepositoryClient: Sendable {
    /// Fetch activities matching the query
    public var fetch: @Sendable (ActivityQuery) async throws -> [ActivityModel]

    /// Add a new activity
    public var add: @Sendable (ActivityModel) async throws -> Void

    /// Update an existing activity
    public var update: @Sendable (ActivityModel) async throws -> Void

    /// Delete an activity by ID
    public var delete: @Sendable (UUID) async throws -> Void

    /// Observe activities matching the query
    public var observe: @Sendable (ActivityQuery) -> AsyncStream<[ActivityModel]>

    public init(
        fetch: @escaping @Sendable (ActivityQuery) async throws -> [ActivityModel],
        add: @escaping @Sendable (ActivityModel) async throws -> Void,
        update: @escaping @Sendable (ActivityModel) async throws -> Void,
        delete: @escaping @Sendable (UUID) async throws -> Void,
        observe: @escaping @Sendable (ActivityQuery) -> AsyncStream<[ActivityModel]>
    ) {
        self.fetch = fetch
        self.add = add
        self.update = update
        self.delete = delete
        self.observe = observe
    }
}

// MARK: - Convenience Initializer from Protocol

public extension ActivityRepositoryClient {
    /// Initialize from any type conforming to ActivityRepositoryProtocol
    init(repository: ActivityRepositoryProtocol) {
        self.init(
            fetch: { query in
                try await repository.fetch(query: query)
            },
            add: { activity in
                try await repository.add(activity)
            },
            update: { activity in
                try await repository.update(activity)
            },
            delete: { id in
                try await repository.delete(id: id)
            },
            observe: { query in
                repository.observe(query: query)
            }
        )
    }
}

// MARK: - Convenience Methods

public extension ActivityRepositoryClient {
    /// Fetch all activities
    func fetchAll() async throws -> [ActivityModel] {
        try await fetch(.all)
    }

    /// Fetch activities from the last week
    func fetchLastWeek() async throws -> [ActivityModel] {
        try await fetch(.lastWeek)
    }

    /// Fetch activities after a specific date
    func fetchActivities(after date: Date?) async throws -> [ActivityModel] {
        try await fetch(ActivityQuery(afterDate: date))
    }
}

// MARK: - TCA Dependency Registration

extension ActivityRepositoryClient: DependencyKey {
    /// Live value uses Core Data repository (will be implemented next)
    public static var liveValue: ActivityRepositoryClient {
        // Temporary implementation using existing ActivityService
        // This will be replaced with CoreDataActivityRepository
        let service = ActivityService(persistence: PersistenceController.shared)
        return ActivityRepositoryClient(
            fetch: { query in
                await service.fetchActivitiesAfter(query.afterDate)
            },
            add: { activity in
                await service.addActivity(activity)
            },
            update: { activity in
                await service.updateActivityFor(
                    id: activity.id,
                    startDate: activity.startDate,
                    endDate: activity.endDate,
                    type: activity.type
                )
            },
            delete: { id in
                // Need to fetch the activity first to delete it
                let activities = await service.fetchActivitiesAfter(nil)
                if let activity = activities.first(where: { $0.id == id }) {
                    await service.deleteActivity(activity)
                }
            },
            observe: { query in
                // Simplified observation - will be improved with CoreDataActivityRepository
                AsyncStream { continuation in
                    Task {
                        let activities = await service.fetchActivitiesAfter(query.afterDate)
                        continuation.yield(activities)
                    }
                }
            }
        )
    }

    /// Test value for unit testing
    public static var testValue: ActivityRepositoryClient {
        ActivityRepositoryClient(
            fetch: { _ in [] },
            add: { _ in },
            update: { _ in },
            delete: { _ in },
            observe: { _ in AsyncStream { _ in } }
        )
    }

    /// Preview value for SwiftUI previews
    public static var previewValue: ActivityRepositoryClient {
        let previewActivities = createPreviewActivities()
        return ActivityRepositoryClient(
            fetch: { query in
                var result = previewActivities
                if let afterDate = query.afterDate {
                    result = result.filter { $0.startDate > afterDate }
                }
                if query.sortOrder == .newestFirst {
                    result.sort { $0.startDate > $1.startDate }
                } else {
                    result.sort { $0.startDate < $1.startDate }
                }
                return result
            },
            add: { _ in },
            update: { _ in },
            delete: { _ in },
            observe: { _ in
                AsyncStream { continuation in
                    continuation.yield(previewActivities)
                }
            }
        )
    }

    private static func createPreviewActivities() -> [ActivityModel] {
        let calendar = Calendar.current
        let now = Date()
        let beginningOfHour = calendar.date(bySetting: .minute, value: 0, of: now)!

        return [
            ActivityModel(
                id: UUID(),
                startDate: calendar.date(byAdding: .hour, value: -2, to: beginningOfHour)!,
                endDate: nil,
                type: .sleep
            ),
            ActivityModel(
                id: UUID(),
                startDate: calendar.date(byAdding: .hour, value: -5, to: beginningOfHour)!,
                endDate: calendar.date(byAdding: .hour, value: -4, to: beginningOfHour)!,
                type: .sleep
            ),
            ActivityModel(
                id: UUID(),
                startDate: calendar.date(byAdding: .hour, value: -17, to: beginningOfHour)!,
                endDate: calendar.date(byAdding: .hour, value: -7, to: beginningOfHour)!,
                type: .sleep
            )
        ]
    }
}

// MARK: - DependencyValues Extension

public extension DependencyValues {
    var activityRepository: ActivityRepositoryClient {
        get { self[ActivityRepositoryClient.self] }
        set { self[ActivityRepositoryClient.self] = newValue }
    }
}
