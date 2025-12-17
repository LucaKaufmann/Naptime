//
//  InMemoryActivityRepositoryTests.swift
//  NaptimeKitTests
//
//  Created by Claude on 2024.
//

import XCTest
@testable import NaptimeKit

final class InMemoryActivityRepositoryTests: XCTestCase {

    var sut: InMemoryActivityRepository!

    override func setUpWithError() throws {
        sut = InMemoryActivityRepository()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    // MARK: - Add Tests

    func testAddActivity() async throws {
        let activity = ActivityModel(
            id: UUID(),
            startDate: Date(),
            endDate: nil,
            type: .sleep
        )

        try await sut.add(activity)

        XCTAssertEqual(sut.count, 1)
        XCTAssertTrue(sut.contains(id: activity.id))
    }

    func testAddDuplicateActivityThrows() async throws {
        let activity = ActivityModel(
            id: UUID(),
            startDate: Date(),
            endDate: nil,
            type: .sleep
        )
        try await sut.add(activity)

        do {
            try await sut.add(activity)
            XCTFail("Expected error to be thrown")
        } catch let error as RepositoryError {
            if case .saveFailed = error {
                // Expected
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    // MARK: - Fetch Tests

    func testFetchAllActivities() async throws {
        let activity1 = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .sleep)
        let activity2 = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .sleep)
        try await sut.add(activity1)
        try await sut.add(activity2)

        let results = try await sut.fetch(query: .all)

        XCTAssertEqual(results.count, 2)
    }

    func testFetchWithAfterDateFilter() async throws {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!

        let recentActivity = ActivityModel(id: UUID(), startDate: now, endDate: nil, type: .sleep)
        let oldActivity = ActivityModel(id: UUID(), startDate: twoDaysAgo, endDate: nil, type: .sleep)

        try await sut.add(recentActivity)
        try await sut.add(oldActivity)

        let query = ActivityQuery(afterDate: yesterday)
        let results = try await sut.fetch(query: query)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, recentActivity.id)
    }

    func testFetchWithBeforeDateFilter() async throws {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!

        let recentActivity = ActivityModel(id: UUID(), startDate: now, endDate: nil, type: .sleep)
        let oldActivity = ActivityModel(id: UUID(), startDate: twoDaysAgo, endDate: nil, type: .sleep)

        try await sut.add(recentActivity)
        try await sut.add(oldActivity)

        let query = ActivityQuery(beforeDate: yesterday)
        let results = try await sut.fetch(query: query)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, oldActivity.id)
    }

    func testFetchWithTypeFilter() async throws {
        let sleepActivity = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .sleep)
        let tummyActivity = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .tummyTime)

        try await sut.add(sleepActivity)
        try await sut.add(tummyActivity)

        let query = ActivityQuery(types: [.sleep])
        let results = try await sut.fetch(query: query)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, sleepActivity.id)
    }

    func testFetchWithLimit() async throws {
        for i in 0..<10 {
            let activity = ActivityModel(
                id: UUID(),
                startDate: Calendar.current.date(byAdding: .hour, value: -i, to: Date())!,
                endDate: nil,
                type: .sleep
            )
            try await sut.add(activity)
        }

        let query = ActivityQuery(limit: 3)
        let results = try await sut.fetch(query: query)

        XCTAssertEqual(results.count, 3)
    }

    func testFetchSortedNewestFirst() async throws {
        let now = Date()
        let hourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        let twoHoursAgo = Calendar.current.date(byAdding: .hour, value: -2, to: now)!

        let activity1 = ActivityModel(id: UUID(), startDate: twoHoursAgo, endDate: nil, type: .sleep)
        let activity2 = ActivityModel(id: UUID(), startDate: hourAgo, endDate: nil, type: .sleep)
        let activity3 = ActivityModel(id: UUID(), startDate: now, endDate: nil, type: .sleep)

        try await sut.add(activity1)
        try await sut.add(activity2)
        try await sut.add(activity3)

        let query = ActivityQuery(sortOrder: .newestFirst)
        let results = try await sut.fetch(query: query)

        XCTAssertEqual(results[0].id, activity3.id)
        XCTAssertEqual(results[1].id, activity2.id)
        XCTAssertEqual(results[2].id, activity1.id)
    }

    func testFetchSortedOldestFirst() async throws {
        let now = Date()
        let hourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        let twoHoursAgo = Calendar.current.date(byAdding: .hour, value: -2, to: now)!

        let activity1 = ActivityModel(id: UUID(), startDate: twoHoursAgo, endDate: nil, type: .sleep)
        let activity2 = ActivityModel(id: UUID(), startDate: hourAgo, endDate: nil, type: .sleep)
        let activity3 = ActivityModel(id: UUID(), startDate: now, endDate: nil, type: .sleep)

        try await sut.add(activity1)
        try await sut.add(activity2)
        try await sut.add(activity3)

        let query = ActivityQuery(sortOrder: .oldestFirst)
        let results = try await sut.fetch(query: query)

        XCTAssertEqual(results[0].id, activity1.id)
        XCTAssertEqual(results[1].id, activity2.id)
        XCTAssertEqual(results[2].id, activity3.id)
    }

    // MARK: - Update Tests

    func testUpdateActivity() async throws {
        let originalDate = Date()
        let activity = ActivityModel(
            id: UUID(),
            startDate: originalDate,
            endDate: nil,
            type: .sleep
        )
        try await sut.add(activity)

        let newEndDate = Date()
        var updatedActivity = activity
        updatedActivity.endDate = newEndDate
        try await sut.update(updatedActivity)

        let fetched = try await sut.fetch(query: .all)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.endDate, newEndDate)
    }

    func testUpdateNonExistentActivityThrows() async throws {
        let activity = ActivityModel(
            id: UUID(),
            startDate: Date(),
            endDate: nil,
            type: .sleep
        )

        do {
            try await sut.update(activity)
            XCTFail("Expected error to be thrown")
        } catch let error as RepositoryError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    // MARK: - Delete Tests

    func testDeleteActivity() async throws {
        let activity = ActivityModel(
            id: UUID(),
            startDate: Date(),
            endDate: nil,
            type: .sleep
        )
        try await sut.add(activity)
        XCTAssertEqual(sut.count, 1)

        try await sut.delete(id: activity.id)

        XCTAssertEqual(sut.count, 0)
        XCTAssertFalse(sut.contains(id: activity.id))
    }

    func testDeleteNonExistentActivityThrows() async throws {
        let nonExistentId = UUID()

        do {
            try await sut.delete(id: nonExistentId)
            XCTFail("Expected error to be thrown")
        } catch let error as RepositoryError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    // MARK: - Reset Tests

    func testReset() async throws {
        let activity = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .sleep)
        try await sut.add(activity)
        XCTAssertEqual(sut.count, 1)

        sut.reset()

        XCTAssertEqual(sut.count, 0)
    }

    // MARK: - Preview Factory Tests

    func testPreviewFactory() async throws {
        let previewRepo = InMemoryActivityRepository.preview()

        let activities = try await previewRepo.fetch(query: .all)

        XCTAssertEqual(activities.count, 3)
    }
}
