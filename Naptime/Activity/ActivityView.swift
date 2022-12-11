//
//  ActivityView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 4.12.2022.
//

import SwiftUI
import ComposableArchitecture
import NapTimeData

struct ActivityView: View {
    let store: Store<Activity.State, Activity.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Text("Activities")
                Button(action: {
                    viewStore.send(.startActivity(.sleep))
                }, label: {
                    Text("Add activity")
                })
                List {
                    ForEach(viewStore.activityHeaderDates, id: \.self) { header in
                        Section(header: ActivitySectionHeaderView(date: header)) {
                            ForEach(viewStore.groupedActivities[header]!) { activity in
                                ActivityRowView(activity: activity)
                            }
                        }
                    }
                }
//                List(viewStore.activities) { activity in
//                    HStack {
//                        Text("\(activity.type.rawValue)")
//                        VStack {
//                            Text(activity.startDate, style: .time)
//                            if let endDate = activity.endDate {
//                                Text(endDate, style: .time)
//                            } else {
//                                Text("...")
//                            }
//                        }
//                    }
//                }
            }
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(
            store: Store(
                initialState: Activity.State(activities: [], groupedActivities: [Date: [ActivityModel]](), activityHeaderDates: []),
                reducer: Activity()))
    }
}
