import SwiftUI
import ComposableArchitecture
import ActivityWatchOS
import Foundation

@main
struct NaptimeWatchApp: App {

    var body: some Scene {
        WindowGroup {
//            WatchActivityView(store: Store(initialState: WatchActivityFeature.State(activities: [],
//                                                     groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>](),
//                                                                          activityHeaderDates: [])) {
//                WatchActivityFeature()
//            })
            WatchRootFeatureView(store: Store(
                initialState: WatchRootFeature.State(activityState: .init(activities: [],
                                                              groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>](),
                                                              activityHeaderDates: []), listeningToStoreChanges: false)) {
                                                                  WatchRootFeature()._printChanges()
                                                              })
        }

//        #if os(watchOS)
//        WKNotificationScene(controller: NotificationController.self, category: "LandmarkNear")
//        #endif
    }
}
