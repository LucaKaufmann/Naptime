//
//  ActivityButtonsView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 28.1.2023.
//

import SwiftUI
import ComposableArchitecture
import NapTimeData

struct ActivityButtonsView: View {
    
    let store: Store<Activity.State, Activity.Action>    
    var body: some View {
        WithViewStore(store) { viewStore in
            ToggleView(isOn: viewStore.binding(\.$isSleeping)) {
                Color("slateInverted")
            }button: {
                Color(viewStore.isSleeping ? "tomatoLight" : "slate")
                    .overlay(ToggleContentView(isOn: viewStore.binding(\.$isSleeping)))
            }.frame(width: 250, height: 75)
        }
    }
}

struct ActivityButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        let date = Date()
        let activities = [ActivityModel(id: UUID(), startDate: date, endDate: nil, type: .sleep)]
        let grouped: [Date: IdentifiedArrayOf<ActivityDetail.State>] = [date: [ActivityDetail.State(id: UUID(), activity: activities.first)]]
        Group {
            ActivityButtonsView(store: Store(
                initialState: Activity.State(activities: activities,
                                             groupedActivities: grouped,
                                             activityHeaderDates: [Date()]),
                reducer: Activity()))
            .previewDisplayName("Light")
            .preferredColorScheme(.light)
            ActivityButtonsView(store: Store(
                initialState: Activity.State(activities: activities,
                                             groupedActivities: grouped,
                                             activityHeaderDates: [Date()]),
                reducer: Activity()))
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
        }

    }
}
