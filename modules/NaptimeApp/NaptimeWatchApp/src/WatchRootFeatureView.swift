//
//  RootView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 30.11.2022.
//


import SwiftUI
import ComposableArchitecture
import ActivityWatchOS
import DesignSystemWatchOS

struct WatchRootFeatureView: View {
    
    @Environment(\.scenePhase) var scenePhase

    let store: Store<WatchRootFeature.State, WatchRootFeature.Action>
    
    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: {$0}) { viewStore in
                WatchActivityView(store: store.scope(state: \.activityState,
                                                action: WatchRootFeature.Action.activityAction))
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        viewStore.send(.onAppear)
                    }
                }
//                .popover(store: store.scope(state: \.$promo, action: Root.Action.promoAction)) { store in
//                    ActivityPromoFeatureView(store: store)
//                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(NaptimeDesignColors.ocean)
    }
}

//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        let rootView = RootView(
//            store: Store(
//                initialState: Root.State(activityState: .init(activities: [],
//                                                              groupedActivities: [Date: [ActivityModel]](),
//                                                              activityHeaderDates: [])),
//                reducer: Root()))
//        return rootView
//    }
//}

