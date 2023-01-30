//
//  ActivityButtonsView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 28.1.2023.
//

import SwiftUI
import ComposableArchitecture

struct ActivityButtonsView: View {
    
    let store: Store<Activity.State, Activity.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.activitiesActive {
                Button(action: {
                    viewStore.send(.endAllActiveActivities)
                }, label: {
                    HStack {
                        Image(systemName: "sleep")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Wake up")
                    }
                }).buttonStyle(RoundedButton(backgroundColor: Color("tomato"), cornerRadius: 12))
            } else {
                Button(action: {
                    viewStore.send(.startActivity(.sleep))
                }, label: {
                    HStack {
                        Image(systemName: "powersleep")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Sleep")
                    }
                }).buttonStyle(RoundedButton(backgroundColor: Color("ocean"), cornerRadius: 12))
            }
        }
    }
}

//struct ActivityButtonsView_Previews: PreviewProvider {
//    static var previews: some View {
//        let date = Date()
//        let activities = [ActivityModel(id: UUID(), startDate: date, endDate: nil, type: .sleep)]
//        let grouped: [Date: IdentifiedArrayOf<ActivityDetail.State>] = [date: [ActivityDetail.State(id: UUID(), activity: activities.first)]]
//        ActivityButtonsView(store: Store(
//            initialState: Activity.State(activities: activities,
//                                         groupedActivities: grouped,
//                                         activityHeaderDates: [Date()]),
//            reducer: Activity()))
//    }
//}