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
                                    //                                ZStack {
                                    //                                    Color("sandLight")
                                    //                                        .offset(x: 34)
                                    //                                        .mask(
                                    //                                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0)]), startPoint: .leading, endPoint: .trailing)
                                    //                                        )
                                    //                                    HStack {
                                    //                                        Rectangle()
                                    //                                            .fill(Color("sandLight"))
                                    //                                            .frame(width: 4, alignment: .center)
                                    //                                            .offset(x: 34)
                                    //                                        Spacer()
                                    //                                            .frame(width: 50)
                                    //                                            .padding(.trailing)
                                    //                                        Text("Awake for \(formatter.string(from: abs(interval)) ?? "")")
                                    //                                            .foregroundColor(Color("sand"))
                                    //                                        Spacer()
                                    //                                    }
                                    //                                }.frame(height: scaleNumber(abs(interval), fromMin: 0, fromMax: 86400, toMin: 20, toMax: 500))
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
