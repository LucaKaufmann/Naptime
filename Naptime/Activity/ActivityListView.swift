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
                            }.buttonStyle(.plain)
                            if let interval = activity.intervalSincePreviousActivity {
                                HStack {
                                    Spacer()
                                        .frame(width: 50)
                                        .padding(.trailing)
                                    Text("Awake for \(formatter.string(from: abs(interval)) ?? "")")
                                        .foregroundColor(Color("sand"))
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
//    func intervalSincePreviousActivity(_ activity: ActivityModel) -> TimeInterval? {
//        guard let index = activities.firstIndex(of: activity) else {
//            return nil
//        }
//        if let nextElement = activities[safe: index + 1] {
//            guard nextElement.endDate != nil else {
//                return nil
//            }
//            return activity.startDate.timeIntervalSince(nextElement.endDate!)
//        }
//
//        return nil
//    }
}
