import SwiftUI

@main
struct NaptimeWatchApp: App {

    var body: some Scene {
        WindowGroup {
            Text("Hello World!")
        }

//        #if os(watchOS)
//        WKNotificationScene(controller: NotificationController.self, category: "LandmarkNear")
//        #endif
    }
}
