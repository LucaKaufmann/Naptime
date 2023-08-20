//
//  RootView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 30.11.2022.
//


import SwiftUI
import ComposableArchitecture
import Activity
import DesignSystem

struct RootView: View {
    
    @Environment(\.scenePhase) var scenePhase

    let store: Store<Root.State, Root.Action>
    
    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: {$0}) { viewStore in
                ActivityView(store: store.scope(state: \.activityState,
                                                action: Root.Action.activityAction))
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        viewStore.send(.onAppear)
                    }
                }
                .popover(store: store.scope(state: \.$promo, action: Root.Action.promoAction)) { store in
                    ActivityPromoFeatureView(store: store)
                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(NaptimeColors.ocean)
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

