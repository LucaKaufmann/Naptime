//
//  NaptimeApp.swift
//  Naptime
//
//  Created by Luca Kaufmann on 19.11.2022.
//

import SwiftUI
import ComposableArchitecture
import NaptimeKit
import Activity

@main
struct NaptimeApp: App {
    
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView(store: Store(
                initialState: Root.State(activityState: .init(activities: [],
                                                              groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>](),
                                                              activityHeaderDates: [], activityTilesState: ActivityTiles.State()), listeningToStoreChanges: false)) {
                                                                  Root()._printChanges()
                                                              })
            .onAppear {
                if UserDefaults.standard.object(forKey: Constants.showAsleepLiveActivitiesKey) == nil {
                    UserDefaults.standard.set(true, forKey: Constants.showAsleepLiveActivitiesKey)
                }
            }
        }
    }
}
