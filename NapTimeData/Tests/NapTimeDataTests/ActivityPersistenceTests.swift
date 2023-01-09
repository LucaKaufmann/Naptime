//
//  ActivityPersistenceTests.swift
//  NaptimeTests
//
//  Created by Luca Kaufmann on 7.12.2022.
//

import XCTest
@testable import NapTimeData

final class ActivityPersistenceTests: XCTestCase {
    
    var sut: ActivityService!
    var persistence: PersistenceController!

    override func setUpWithError() throws {
        persistence = PersistenceController.preview
        sut = ActivityService(persistence: persistence)
    }

    override func tearDownWithError() throws {
        sut = nil
        persistence = nil
    }

    func testAddingActivity() async throws {
        let testActivity = ActivityModel(id: UUID(), startDate: Date(), endDate: Date(), type: .sleep)
        await sut.addActivity(testActivity)
        
        let activity = try await persistence.fetch(model: ActivityPersistenceModel.self, predicate: NSPredicate(format: "id == %@", testActivity.id as CVarArg)).first
        
        XCTAssertNotNil(activity)
    }
    
    func testUpdateActivity() async throws {
        
        let testActivity = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .sleep)
        await sut.addActivity(testActivity)
        
        let newStartDate = Calendar.current.date(from: DateComponents(year: 2022, month: 12, day: 7, hour: 10, minute: 41))
        let newEndDate = Calendar.current.date(from: DateComponents(year: 2022, month: 12, day: 7, hour: 11, minute: 41))
        let newType = ActivityType.tummyTime
        await sut.updateActivityFor(id: testActivity.id, startDate: newStartDate, endDate: newEndDate, type: newType)
        
        let activity = try await persistence.fetch(model: ActivityPersistenceModel.self, predicate: NSPredicate(format: "id == %@", testActivity.id as CVarArg)).first
        
        XCTAssertNotNil(activity)
        XCTAssertTrue(activity?.startDate == newStartDate)
        XCTAssertTrue(activity?.endDate == newEndDate)
        XCTAssertTrue(activity?.activityTypeValue == newType.rawValue)
    }
    
    func testEndActivity() async throws {
        
        let testActivity = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .sleep)
        await sut.addActivity(testActivity)
        
        await sut.endActivity(testActivity.id)
        
        let activity = try await persistence.fetch(model: ActivityPersistenceModel.self, predicate: NSPredicate(format: "id == %@", testActivity.id as CVarArg)).first
        
        XCTAssertNotNil(activity)
        XCTAssertNotNil(activity?.endDate)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
