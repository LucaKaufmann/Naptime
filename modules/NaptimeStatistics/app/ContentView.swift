import SwiftUI
import NaptimeStatistics
import ComposableArchitecture

public struct ContentView: View {
    public init() {}

    public var body: some View {
        TabView {
            SleepTodayStatisticsFeatureView(store: Store(initialState: SleepTodayStatisticsFeature.State()) {
                SleepTodayStatisticsFeature()
            }).tabItem {
                Text("Sleep today")
            }
            NapTodayStatisticsFeatureView(store: Store(initialState: NapTodayStatisticsFeature.State()) {
                NapTodayStatisticsFeature()
            }).tabItem {
                Text("Nap today")
            }
            BedtimeStatisticsFeatureView(store: Store(initialState: BedtimeStatisticsFeature.State()) {
                BedtimeStatisticsFeature()
            }).tabItem {
                Text("Bedtime")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
