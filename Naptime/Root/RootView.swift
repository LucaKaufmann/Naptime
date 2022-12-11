//
//  RootView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 30.11.2022.
//


import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: Store<Root.State, Root.Action>
    var body: some View {
        WithViewStore(self.store.stateless) { viewStore in
            TabView {
                ActivityView(store: store.scope(state: \.activityState,
                                                action: Root.Action.activityAction))
                .tabItem {
                  Image(systemName: "list.bullet")
                  Text("Activities")
                }
            }.onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let rootView = RootView(
            store: Store(
                initialState: Root.State(activityState: .init(activities: [],
                                                              groupedActivities: [Date: [ActivityModel]](),
                                                              activityHeaderDates: [])),
                reducer: Root()))
        return rootView
    }
}

