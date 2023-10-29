import SwiftUI
import ComposableArchitecture
import ActivityWatchOS
import Foundation

@main
struct NaptimeWatchApp: App {

    var body: some Scene {
        WindowGroup {
            ActivityView(store: Store(initialState: ActivityFeature.State(activities: [],
                                                     groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>](),
                                                                          activityHeaderDates: [], activityTilesState: ActivityTiles.State())) {
                ActivityFeature()
            })
//            RootView(store: Store(
//                initialState: Root.State(activityState: .init(activities: [],
//                                                              groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>](),
//                                                              activityHeaderDates: [], activityTilesState: ActivityTiles.State()), listeningToStoreChanges: false)) {
//                                                                  Root()
//                                                              })
        }

//        #if os(watchOS)
//        WKNotificationScene(controller: NotificationController.self, category: "LandmarkNear")
//        #endif
    }
}
