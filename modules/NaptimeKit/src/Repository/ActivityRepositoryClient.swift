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
    /// Live value uses CoreDataActivityRepository
    public static var liveValue: ActivityRepositoryClient {
        let repository = CoreDataActivityRepository.shared
        return ActivityRepositoryClient(repository: repository)
    }

    /// Test value uses InMemoryActivityRepository
    public static var testValue: ActivityRepositoryClient {
        let repository = InMemoryActivityRepository()
        return ActivityRepositoryClient(repository: repository)
    }

    /// Preview value uses InMemoryActivityRepository with sample data
    public static var previewValue: ActivityRepositoryClient {
        let repository = InMemoryActivityRepository.preview()
        return ActivityRepositoryClient(repository: repository)
    }
}

// MARK: - DependencyValues Extension

public extension DependencyValues {
    var activityRepository: ActivityRepositoryClient {
        get { self[ActivityRepositoryClient.self] }
        set { self[ActivityRepositoryClient.self] = newValue }
    }
}
