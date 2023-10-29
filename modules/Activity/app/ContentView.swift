import SwiftUI
import ComposableArchitecture
#if os(macOS)
import Activity
#elseif os(iOS)
import Activity
#elseif os(tvOS) || os(watchOS)
import ActivityWatchOS
#endif

public struct ContentView: View {
    public init() {}

    public var body: some View {
        ActivityView(store: Store(initialState: ActivityFeature.State(activities: [], groupedActivities: [:], activityHeaderDates: [], activityTilesState: .init())) {
            ActivityFeature()
        })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
