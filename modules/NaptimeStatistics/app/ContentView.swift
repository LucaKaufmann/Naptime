import SwiftUI
import NaptimeStatistics
import ComposableArchitecture

public struct ContentView: View {
    public init() {}

    public var body: some View {
        SleepTodayStatisticsFeatureView(store: Store(initialState: SleepTodayStatisticsFeature.State()) {
            SleepTodayStatisticsFeature()
        })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
