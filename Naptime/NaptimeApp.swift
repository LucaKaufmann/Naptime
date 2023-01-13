//
//  NaptimeApp.swift
//  Naptime
//
//  Created by Luca Kaufmann on 19.11.2022.
//

import SwiftUI
import ComposableArchitecture
import NapTimeData

@main
struct NaptimeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView(store: Store(
                initialState: Root.State(activityState: .init(activities: [],
                                                              groupedActivities: [Date: [ActivityModel]](),
                                                              activityHeaderDates: [],
                                                              activityDetailState: ActivityDetail.State(activity: nil))),
                reducer: Root()))
        }
    }
}
