//
//  ActivityView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 4.12.2022.
//

import SwiftUI
import ComposableArchitecture
import CloudKit

#if os(macOS) || os(iOS) || os(tvOS)
import DesignSystem
import NaptimeKit
import NaptimeSettings
import NaptimeStatistics
import ScalingHeaderScrollView
#elseif os(watchOS)
import DesignSystemWatchOS
import NaptimeKitWatchOS
import NaptimeSettingsWatchOS
import NaptimeStatisticsWatchOS
#endif

public struct ActivityView: View {
    
    @State var activeShare: CKShare?
    
    let store: StoreOf<ActivityFeature>
    
    private let minHeight = 0.0
    private let maxHeight = 320.0
    
    public init(store: StoreOf<ActivityFeature>) {
        self.store = store
        #if os(macOS) || os(iOS) || os(tvOS)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "sandLight")
        UISegmentedControl.appearance().backgroundColor =
        UIColor(NaptimeDesignColors.slate.opacity(0.3))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.primary)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.secondary)], for: .normal)
        
        UIScrollView.appearance().backgroundColor = .clear
        #endif
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
#if os(macOS) || os(iOS) || os(tvOS)
                ScalingHeaderScrollView {
                    ZStack(alignment: .center) {
                        VStack {
                            Spacer()
                            ActivityTilesView(store: store.scope(state: \.activityTilesState, action: ActivityFeature.Action.activityTiles))
                                .frame(height: max(maxHeight, 0))
                            Spacer()
                        }
                        VStack(alignment: .center) {
                            Spacer()
                        }
                        VStack {
                            Spacer()
                            IfLetStore(
                                store.scope(state: \.lastActivityTimerState,
                                            action: ActivityFeature.Action.activityTimerAction),
                                then: { store in
                                    TimerFeatureView(store: store,
                                                     label: viewStore.isSleeping ? "Asleep for" : "Awake for",
                                                     fontSize: 18,
                                                     fontDesign: .rounded)
                                    .foregroundColor(NaptimeDesignColors.sand)
                                    .padding()
                                    
                                },
                                else: { Text("Time for a nap!")
                                        .font(.headline)
                                        .foregroundColor(NaptimeDesignColors.sand)
                                        .padding()
                                    
                                }
                            )
                        }
                    }
                    .background(
                        ZStack {
                            NaptimeDesignColors.ocean
                            Circle()
                                .stroke(NaptimeDesignColors.slate, lineWidth: 265)
                                .offset(y: maxHeight+65)
                        }
                            .edgesIgnoringSafeArea(.all)
                            .allowsHitTesting(false)
                    )
                } content: {
                    ActivityListView(store: store)
                        .background(NaptimeDesignColors.slate.ignoresSafeArea())
                }
                .height(min: minHeight, max: maxHeight)
                .refreshable {
                    viewStore.send(.refreshActivities)
                }
                #endif
                sleepToggle
            }
            .scrollContentBackground(.hidden)
            .ignoresSafeArea()
            .background(
                NaptimeDesignColors.slate
            )
            .navigationDestination(
                store: self.store.scope(state: \.$settings, action: ActivityFeature.Action.settings)
            ) { store in
                SettingsView(store: store)
            }
            .sheet(store: self.store.scope(state: \.$sleepTodaySheet, action: ActivityFeature.Action.sleepTodaySheet)
            ) { store in
                SleepTodayStatisticsFeatureView(store: store)
            }
            .sheet(store: self.store.scope(state: \.$napsTodaySheet, action: ActivityFeature.Action.napsTodaySheet)
            ) { store in
                NapTodayStatisticsFeatureView(store: store)
            }
            .sheet(store: self.store.scope(state: \.$bedtimeSheet, action: ActivityFeature.Action.bedtimeSheet)
            ) { store in
                BedtimeStatisticsFeatureView(store: store)
            }
            .toolbar {
            #if os(macOS) || os(iOS) || os(tvOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewStore.send(.refreshActivities)
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(NaptimeDesignColors.sandLight)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Picker("Activities", selection: viewStore.$selectedTimeRange) {
                        Text("7d").tag(ActivityTimeRange.week)
                        Text("All").tag(ActivityTimeRange.all)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 30)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewStore.send(.settingsButtonTapped)
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(NaptimeDesignColors.sandLight)
                    }
                }
                #endif
            }
        }.edgesIgnoringSafeArea(.vertical)
    }
    
    private var sleepToggle: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            VStack {
                Spacer()
                #if os(iOS)
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .regular))
                        .frame(height: 180)
                        .padding(.bottom, -100)
                    HStack {
                        ActivityButtonsView(store: store)
                    }
                }
                #endif
            }
            .ignoresSafeArea()
            .padding(.bottom, 40)
        }
    }
}


struct BackgroundShape : Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let topLeftCorner = rect.height / 3
        let startingPoint = CGPoint(
            x: 0,
            y: topLeftCorner
        )
        p.move(
            to: startingPoint
        )
        //        p.addLine(
        //            to: CGPoint(
        //                x: rect.width,
        //                y: topLeftCorner)
        //        )
        //        p.addArc(center: CGPoint(x: rect.width/2, y:rect.height), radius: radius, startAngle: .degrees(-125), endAngle: .degrees(-55), clockwise: false)
        p.addQuadCurve(to: CGPoint(x: rect.width, y: topLeftCorner), control: CGPoint(x: rect.width/2, y: topLeftCorner-60))
        p.addLine(
            to: CGPoint(
                x: rect.width,
                y: rect.height)
        )
        p.addLine(
            to: CGPoint(
                x: 0,
                y: rect.height)
        )
        p.addLine(
            to: startingPoint
        )
        
        return p
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        let date = Date()
        let activities = [ActivityModel(id: UUID(), startDate: date, endDate: nil, type: .sleep)]
        let grouped: [Date: IdentifiedArrayOf<ActivityDetail.State>] = [date: [ActivityDetail.State(id: UUID(), activity: activities.first)]]
        ActivityView(
            store: Store(
                initialState: ActivityFeature.State(activities: activities,
                                                    groupedActivities: grouped,
                                                    activityHeaderDates: [date], activityTilesState: ActivityTiles.State())) { ActivityFeature() })
    }
}
