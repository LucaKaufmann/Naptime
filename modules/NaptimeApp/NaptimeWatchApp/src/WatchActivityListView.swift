//
//  WatchActivityListView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 28.1.2023.
//

import SwiftUI
import ComposableArchitecture
import NaptimeKitWatchOS
import DesignSystemWatchOS
import ActivityWatchOS

struct WatchActivityListView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let store: Store<WatchActivityFeature.State, WatchActivityFeature.Action>
    
    var formatter: DateComponentsFormatter = {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute, .second]
          formatter.unitsStyle = .abbreviated
          formatter.zeroFormattingBehavior = .pad
          return formatter
      }()

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                if viewStore.activityHeaderDates.count == 0 {
                    Spacer()
                #if os(macOS) || os(iOS) || os(tvOS)

                    HStack {
                        Spacer()
                        ZStack {
                            Color(.black)
                            
                                .mask(
                                    
                                    DesignSystemAsset.sleepingTeddy.swiftUIImage
                                        .resizable()
                                        .colorInvert()
                                        .luminanceToAlpha()
                                )
                                .clipShape(Circle())

                            Circle()
                                .stroke(.black, lineWidth: 2)
//                            if viewStore.loading {
//                                LoadingBadgeView(title: "Loading", color: Color("slate").opacity(0.8))
//                                    .frame(width: 120, height: 80)
//                            }
                        }
                        .frame(width: 250, height: 250)
                        Spacer()
                    }
                #else
                    Text("Nothing here yet")
                        .foregroundColor(.black)
                #endif

                    Spacer()
                } else {
                    if let first = viewStore.activities.first {
                        WatchActivityRowView(activity: first)
                    }
//                    ActivityWeekList(store: store)
                }
            }
        }
    }
}

struct ActivityWeekList: View {
    
    let store: StoreOf<WatchActivityFeature>
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            LazyVStack {
//                ForEach(viewStore.activityHeaderDates, id: \.self) { header in
//                    Section(header: ActivitySectionHeaderView(date: header)) {
//                        ForEach(viewStore.groupedActivities[header]!, id: \.id) { activity in
//                            VStack(alignment: .leading) {
//                                NavigationLink(
//                                    tag: activity.id,
//                                    selection: viewStore.binding(
//                                        get: \.selectedActivityId,
//                                        send: ActivityFeature.Action.setSelectedActivityId
//                                    )
//                                ){
////                                    IfLetStore(
////                                        store.scope(state: \.selectedActivity,
////                                                    action: ActivityFeature.Action.activityDetailAction),
////                                        then: ActivityDetailView.init(store:),
////                                        else: { Text("Nothing here") }
////                                    )
////                                } label: {
//                                    ActivityRowView(activity: activity.activity!)
//                                        .frame(height: scaleNumber(abs(activity.activity!.duration), fromMin: 0, fromMax: 86400, toMin: 40, toMax: 500))
////                                }.buttonStyle(.plain)
//                                if let interval = activity.intervalSincePreviousActivity {
//                                    AwakeRow(interval: interval)
//                                }
//                            }
//                        }
//                    }
//                }
            }
        }
    }
}

struct ActivityAllList: View {
    
    let store: StoreOf<WatchActivityFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0.activityHeaderDates }) { viewStore in
            LazyVStack {
                ForEach(viewStore.state, id: \.self) { date in
                    Text("\(date)")
                }
            }
        }
    }
}

