//
//  NaptimeTests.swift
//  NaptimeTests
//
//  Created by Luca Kaufmann on 19.11.2022.
//

import XCTest
import ComposableArchitecture
import NapTimeData

@testable import Naptime

final class NaptimeTests: XCTestCase {
    
    var testActivityModels = [ActivityModel]()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let firstActivityDate = dateFormatter.date(from: "2022-12-05 12:00")
        let secondActivityDate = dateFormatter.date(from: "2022-12-05 23:59")
        let thirdActivityDate = dateFormatter.date(from: "2022-12-06 08:00")
        
        let firstActivity = ActivityModel(id: UUID(uuidString: "7AE07850-6AE1-4DDA-8351-6D157F90496A")!,
                                          startDate: firstActivityDate!,
                                          endDate: Calendar.current.date(byAdding: .init(hour: 8), to: firstActivityDate!),
                                          type: .sleep)
        testActivityModels.append(firstActivity)
        
        let secondActivity =  ActivityModel(id: UUID(uuidString: "271EE86B-188C-4130-AF38-D30D4B7F285E")!,
                                            startDate: secondActivityDate!,
                                            endDate: Calendar.current.date(byAdding: .init(hour: 8), to: secondActivityDate!),
                                            type: .sleep)
        testActivityModels.append(secondActivity)

        let thirdActivity =  ActivityModel(id: UUID(uuidString: "BED4A302-65BD-4D27-99EF-E8E4A4D7934A")!,
                                            startDate: thirdActivityDate!,
                                            endDate: Calendar.current.date(byAdding: .init(hour: 8), to: thirdActivityDate!),
                                            type: .sleep)
        testActivityModels.append(thirdActivity)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOnAppear() {
//        let store = TestStore(
//            initialState: Root.State(activityState: .init(activities: [],
//                                                          groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>](),
//                                                          activityHeaderDates: [])),
//            reducer: Root())
//        store.send(.onAppear)
//        store.receive(.loadedActivities(.success(testActivityModels))) { state in
//            state.activityState.activities = self.testActivityModels
//        }
//      let store = TestStore(
//        initialState: RepositoryState(),
//        reducer: repositoryReducer,
//        environment: SystemEnvironment(
//          environment: RepositoryEnvironment(repositoryRequest: testRepositoryEffect),
//          mainQueue: { self.testScheduler.eraseToAnyScheduler() },
//          decoder: { JSONDecoder() }))
//      store.send(.onAppear)
//      testScheduler.advance()
//      store.receive(.dataLoaded(.success(testRepositories))) { state in
//        state.repositories = self.testRepositories
//      }

    }

}
