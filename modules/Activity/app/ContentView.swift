import SwiftUI
import ComposableArchitecture
import Activity

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
