import SwiftUI
import ComposableArchitecture
import NaptimeSettings

public struct ContentView: View {
    public init() {}

    public var body: some View {
        SettingsView(store: Store(initialState: .init(showAsleepLiveAction: true,
                                                      showAwakeLiveAction: true)) {
            SettingsFeature()
        })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
