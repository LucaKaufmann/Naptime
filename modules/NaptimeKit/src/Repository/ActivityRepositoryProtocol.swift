//
//  ActivityRepositoryProtocol.swift
//  NaptimeKit
//
//  Created by Claude on 2024.
//

import Foundation

/// Protocol defining the contract for activity persistence operations
///
/// This protocol abstracts the persistence layer, allowing different implementations
/// such as Core Data, GRDB, SwiftData, or in-memory storage for testing.
public protocol ActivityRepositoryProtocol: Sendable {
    /// Fetch activities matching the given query
    /// - Parameter query: The query parameters for filtering and sorting
    /// - Returns: An array of activities matching the query
    func fetch(query: ActivityQuery) async throws -> [ActivityModel]

    /// Add a new activity to the repository
    /// - Parameter activity: The activity to add
    func add(_ activity: ActivityModel) async throws

    /// Update an existing activity in the repository
    /// - Parameter activity: The activity with updated values
    func update(_ activity: ActivityModel) async throws

    /// Delete an activity from the repository
    /// - Parameter id: The ID of the activity to delete
    func delete(id: UUID) async throws

    /// Observe activities matching the query
    /// - Parameter query: The query parameters for filtering and sorting
    /// - Returns: An async stream that emits arrays of activities when data changes
    func observe(query: ActivityQuery) -> AsyncStream<[ActivityModel]>
}

// MARK: - Convenience Extensions

public extension ActivityRepositoryProtocol {
    /// Fetch all activities
    func fetchAll() async throws -> [ActivityModel] {
        try await fetch(query: .all)
    }

    /// Fetch a single activity by ID
    /// - Parameter id: The ID of the activity to fetch
    /// - Returns: The activity if found, nil otherwise
    func fetch(id: UUID) async throws -> ActivityModel? {
        let results = try await fetch(query: .all)
        return results.first { $0.id == id }
    }

    /// Fetch activities from the last week
    func fetchLastWeek() async throws -> [ActivityModel] {
        try await fetch(query: .lastWeek)
    }
}
