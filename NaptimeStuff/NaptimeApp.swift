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
    
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView(store: Store(
                initialState: Root.State(activityState: .init(activities: [],
                                                              groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>](),
                                                              activityHeaderDates: [], activityTilesState: ActivityTiles.State()), listeningToStoreChanges: false),
                reducer: Root()))
            .onAppear {
                if UserDefaults.standard.object(forKey: Constants.showAsleepLiveActivitiesKey) == nil {
                    UserDefaults.standard.set(true, forKey: Constants.showAsleepLiveActivitiesKey)
                }
            }
        }
    }
}