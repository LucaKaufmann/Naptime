//
//  InMemoryActivityRepository.swift
//  NaptimeKit
//
//  Created by Claude on 2024.
//

import Foundation

/// An in-memory implementation of ActivityRepositoryProtocol for testing
///
/// This repository stores activities in memory and is useful for:
/// - Unit testing features without Core Data
/// - SwiftUI previews
/// - Development and prototyping
public final class InMemoryActivityRepository: ActivityRepositoryProtocol, @unchecked Sendable {
    /// Internal storage of activities (protected by lock)
    private var activities: [ActivityModel]

    /// Active observation continuations
    private var continuations: [UUID: AsyncStream<[ActivityModel]>.Continuation] = [:]

    /// Lock for thread-safe access
    private let lock = NSLock()

    /// Initialize with optional seed data
    /// - Parameter activities: Initial activities to populate the repository
    public init(activities: [ActivityModel] = []) {
        self.activities = activities
    }

    // MARK: - ActivityRepositoryProtocol

    public func fetch(query: ActivityQuery) async throws -> [ActivityModel] {
        lock.lock()
        defer { lock.unlock() }

        var result = activities

        // Apply filters
        if let afterDate = query.afterDate {
            result = result.filter { $0.startDate > afterDate }
        }

        if let beforeDate = query.beforeDate {
            result = result.filter { $0.startDate < beforeDate }
        }

        if let types = query.types, !types.isEmpty {
            result = result.filter { types.contains($0.type) }
        }

        // Apply sorting
        switch query.sortOrder {
        case .newestFirst:
            result.sort { $0.startDate > $1.startDate }
        case .oldestFirst:
            result.sort { $0.startDate < $1.startDate }
        }

        // Apply limit
        if let limit = query.limit, limit > 0 {
            result = Array(result.prefix(limit))
        }

        return result
    }

    public func add(_ activity: ActivityModel) async throws {
        lock.lock()

        // Check for duplicates
        guard !activities.contains(where: { $0.id == activity.id }) else {
            lock.unlock()
            throw RepositoryError.saveFailed(message: "Activity with id \(activity.id) already exists")
        }

        activities.append(activity)
        lock.unlock()

        notifyObservers()
    }

    public func update(_ activity: ActivityModel) async throws {
        lock.lock()

        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else {
            lock.unlock()
            throw RepositoryError.notFound(id: activity.id)
        }

        activities[index] = activity
        lock.unlock()

        notifyObservers()
    }

    public func delete(id: UUID) async throws {
        lock.lock()

        guard activities.contains(where: { $0.id == id }) else {
            lock.unlock()
            throw RepositoryError.notFound(id: id)
        }

        activities.removeAll { $0.id == id }
        lock.unlock()

        notifyObservers()
    }

    public func observe(query: ActivityQuery) -> AsyncStream<[ActivityModel]> {
        let id = UUID()

        return AsyncStream { continuation in
            // Store continuation for future updates
            self.storeContinuation(id: id, continuation: continuation)

            // Yield initial value
            Task {
                do {
                    let initialActivities = try await self.fetch(query: query)
                    continuation.yield(initialActivities)
                } catch {
                    continuation.finish()
                }
            }

            continuation.onTermination = { [weak self] _ in
                self?.removeContinuation(id: id)
            }
        }
    }

    // MARK: - Private Helpers

    private func storeContinuation(id: UUID, continuation: AsyncStream<[ActivityModel]>.Continuation) {
        lock.lock()
        defer { lock.unlock() }
        continuations[id] = continuation
    }

    private func removeContinuation(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        continuations.removeValue(forKey: id)
    }

    private func notifyObservers() {
        lock.lock()
        let currentActivities = activities
        let currentContinuations = continuations.values
        lock.unlock()

        for continuation in currentContinuations {
            continuation.yield(currentActivities)
        }
    }

    // MARK: - Test Helpers

    /// Reset the repository to empty state
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        activities = []
    }

    /// Get the current count of activities
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return activities.count
    }

    /// Check if an activity exists
    public func contains(id: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return activities.contains { $0.id == id }
    }
}

// MARK: - Preview Data

public extension InMemoryActivityRepository {
    /// Create a repository pre-populated with sample data for previews
    static func preview() -> InMemoryActivityRepository {
        let calendar = Calendar.current
        let now = Date()
        let beginningOfHour = calendar.date(bySetting: .minute, value: 0, of: now)!

        let activities = [
            ActivityModel(
                id: UUID(uuidString: "7AE07850-6AE1-4DDA-8351-6D157F90496A")!,
                startDate: calendar.date(byAdding: .hour, value: -17, to: beginningOfHour)!,
                endDate: calendar.date(byAdding: .hour, value: -7, to: beginningOfHour),
                type: .sleep
            ),
            ActivityModel(
                id: UUID(uuidString: "271EE86B-188C-4130-AF38-D30D4B7F285E")!,
                startDate: calendar.date(byAdding: .hour, value: -5, to: beginningOfHour)!,
                endDate: calendar.date(byAdding: .hour, value: -4, to: beginningOfHour),
                type: .sleep
            ),
            ActivityModel(
                id: UUID(uuidString: "BED4A302-65BD-4D27-99EF-E8E4A4D7934A")!,
                startDate: calendar.date(byAdding: .hour, value: -2, to: beginningOfHour)!,
                endDate: nil,
                type: .sleep
            )
        ]

        return InMemoryActivityRepository(activities: activities)
    }
}
