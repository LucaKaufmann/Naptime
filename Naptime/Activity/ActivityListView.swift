//
//  ActivityListView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 28.1.2023.
//

import SwiftUI
import ComposableArchitecture
import NapTimeData

struct ActivityListView: View {
    
    let store: Store<Activity.State, Activity.Action>
    
    var formatter: DateComponentsFormatter = {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute, .second]
          formatter.unitsStyle = .abbreviated
          formatter.zeroFormattingBehavior = .pad
          return formatter
      }()

    var body: some View {
        WithViewStore(store) { viewStore in
//            ActivityListAwakeRow(store: store)
            VStack {
                if viewStore.activityHeaderDates.count == 0 {
                    Spacer()
                    HStack {
                        Spacer()
                        Image("sleeping_teddy")
                            .resizable()
                            .frame(width: 250, height: 250)
                            .blendMode(.darken)
                        Spacer()
                    }.opacity(0.5)
                    Spacer()
                } else {
                    ForEach(viewStore.activityHeaderDates, id: \.self) { header in
                        Section(header: ActivitySectionHeaderView(date: header)) {
                            ForEach(viewStore.groupedActivities[header]!, id: \.id) { activity in
                                VStack(alignment: .leading) {
                                    NavigationLink(
                                        tag: activity.id,
                                        selection: viewStore.binding(
                                            get: \.selectedActivityId,
                                            send: Activity.Action.setSelectedActivityId
                                        )
                                    ){
                                        IfLetStore(
                                            store.scope(state: \.selectedActivity,
                                                        action: Activity.Action.activityDetailAction),
                                            then: ActivityDetailView.init(store:),
                                            else: { Text("Nothing here") }
                                        )
                                    } label: {
                                        ActivityRowView(activity: activity.activity!)
                                            .frame(height: scaleNumber(abs(activity.activity!.duration), fromMin: 0, fromMax: 86400, toMin: 40, toMax: 500))
                                    }.buttonStyle(.plain)
                                    if let interval = activity.intervalSincePreviousActivity {
                                        AwakeRow(interval: interval)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
