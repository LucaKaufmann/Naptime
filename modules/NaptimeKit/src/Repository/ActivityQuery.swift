//
//  ActivityQuery.swift
//  NaptimeKit
//
//  Created by Claude on 2024.
//

import Foundation

/// A query object for filtering and sorting activities
public struct ActivityQuery: Equatable, Sendable {
    /// Filter activities that started after this date
    public var afterDate: Date?

    /// Filter activities that started before this date
    public var beforeDate: Date?

    /// Filter by specific activity types (nil means all types)
    public var types: [ActivityType]?

    /// Limit the number of results (nil or 0 means no limit)
    public var limit: Int?

    /// Sort order for results
    public var sortOrder: SortOrder

    /// Sort order options
    public enum SortOrder: Equatable, Sendable {
        case newestFirst
        case oldestFirst
    }

    public init(
        afterDate: Date? = nil,
        beforeDate: Date? = nil,
        types: [ActivityType]? = nil,
        limit: Int? = nil,
        sortOrder: SortOrder = .newestFirst
    ) {
        self.afterDate = afterDate
        self.beforeDate = beforeDate
        self.types = types
        self.limit = limit
        self.sortOrder = sortOrder
    }

    /// A default query that fetches all activities sorted by newest first
    public static var all: ActivityQuery {
        ActivityQuery()
    }

    /// Query for activities in the last week
    public static var lastWeek: ActivityQuery {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        return ActivityQuery(afterDate: weekAgo)
    }
}
