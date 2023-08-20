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
    
    let store: Store<ActivityFeature.State, ActivityFeature.Action>    
    var body: some View {
        WithViewStore(store) { viewStore in
            ToggleView(isOn: viewStore.binding(\.$isSleeping)) {
                Color.clear
                    .overlay(
                        RoundedRectangle(cornerRadius: 12).strokeBorder(Color("slate"), lineWidth: 5)
                        
                    )
            }button: {
                Color(viewStore.isSleeping ? "tomatoLight" : "ocean")
                    .overlay(ToggleContentView(isOn: viewStore.binding(\.$isSleeping)))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .frame(width: 250, height: 60)
            .shadow(color: Color("slateDark").opacity(0.2), radius: 2)
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
                initialState: ActivityFeature.State(activities: activities,
                                             groupedActivities: grouped,
                                             activityHeaderDates: [Date()], activityTilesState: ActivityTiles.State()),
                reducer: ActivityFeature()))
            .previewDisplayName("Light")
            .preferredColorScheme(.light)
            ActivityButtonsView(store: Store(
                initialState: ActivityFeature.State(activities: activities,
                                             groupedActivities: grouped,
                                             activityHeaderDates: [Date()], activityTilesState: ActivityTiles.State()),
                reducer: ActivityFeature()))
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
        }

    }
}
