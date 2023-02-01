//
//  RootView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 30.11.2022.
//


import SwiftUI
import ComposableArchitecture
import NapTimeData

struct RootView: View {
    
    @Environment(\.scenePhase) var scenePhase

    let store: Store<Root.State, Root.Action>
    
    var body: some View {
        WithViewStore(self.store.stateless) { viewStore in
            ActivityView(store: store.scope(state: \.activityState,
                                            action: Root.Action.activityAction))
            .onChange(of: scenePhase) { newPhase in
                           if newPhase == .active {
                               viewStore.send(.onAppear)
                           }
                       }
//            .onAppear {
//                viewStore.send(.onAppear)
//            }
        }
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

