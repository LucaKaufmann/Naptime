//
//  ActivityView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 4.12.2022.
//

import SwiftUI
import ComposableArchitecture
import NapTimeData
import ScalingHeaderScrollView
import CloudKit

struct ActivityView: View {
    
    @State private var showShareSheet = false
    @State var activeShare: CKShare?
    
    let store: StoreOf<Activity>
    
    private let minHeight = 0.0
    private let maxHeight = 322.0
    
    init(store: StoreOf<Activity>) {
        self.store = store
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "sandLight")
        UISegmentedControl.appearance().backgroundColor =
        UIColor(Color("slate").opacity(0.3))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.primary)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.secondary)], for: .normal)
    }
    
    var body: some View {
        GeometryReader { geometry in
            WithViewStore(self.store) { viewStore in
                ZStack {
                    VStack(spacing: 0) {
                        Color("ocean")
                            .frame(height: max(geometry.size.height / 3, 0))
                        Color("slate")
                    }
                    ScalingHeaderScrollView {
                        ZStack {
                            VStack {
                                Spacer()
                                ActivityTilesView(store: store.scope(state: \.activityTilesState, action: Activity.Action.activityTiles))
                                    .frame(height: max(geometry.size.height / 3, 0))
                                //                                    .padding(.top, 25)
                                Spacer()
                            }
                            VStack {
                                Spacer()
                                BackgroundShape()
                                    .foregroundColor(Color("slate"))
                                    .edgesIgnoringSafeArea(.all)
                                    .frame(width: geometry.size.width, height: 60)
                            }
                            VStack {
                                Spacer()
                                IfLetStore(
                                    store.scope(state: \.lastActivityTimerState,
                                                action: Activity.Action.activityTimerAction),
                                    then: { store in
                                        TimerFeatureView(store: store,
                                                         label: viewStore.isSleeping ? "Asleep for" : "Awake for",
                                                         fontSize: 18,
                                                         fontDesign: .rounded)
                                        .foregroundColor(Color("sand"))
                                        .padding()
                                        
                                    },
                                    else: { Text("Time for a nap!")
                                            .font(.headline)
                                            .foregroundColor(Color("sand"))
                                            .padding()
                                        
                                    }
                                )
                            }
                        }
                    } content: {
                        ActivityListView(store: store)
                            .background(Color("slate").ignoresSafeArea())
                    }
                    .height(min: minHeight, max: maxHeight)
                    .refreshable {
                        viewStore.send(.refreshActivities)
                    }
                    sleepToggle
                }
                .ignoresSafeArea()
                .navigationDestination(
                      store: self.store.scope(state: \.$settings, action: Activity.Action.settings)
                    ) { store in
                      SettingsView(store: store)
                    }
                .sheet(isPresented: viewStore.binding(\.$showShareSheet), content: { shareView(share: viewStore.share) })
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.refreshActivities)
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(Color("sandLight"))
                        }
                    }
                    ToolbarItem(placement: .principal) {
                                        Picker("Activities", selection: viewStore.binding(\.$selectedTimeRange)) {
                                            Text("7d").tag(ActivityTimeRange.week)
                                            Text("All").tag(ActivityTimeRange.all)
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                        .padding(.horizontal, 30)
                                    }
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button {
//                            viewStore.send(.shareTapped)
//                        } label: {
//                            Image(systemName: "square.and.arrow.up")
//                                .foregroundColor(Color("sandLight"))
//                        }
//                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewStore.send(.settingsButtonTapped)
                        } label: {
                            Image(systemName: "gear")
                                .foregroundColor(Color("sandLight"))
                        }
                    }
                }
            }
        }.edgesIgnoringSafeArea(.vertical)
    }
    
    private var sleepToggle: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Spacer()
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .regular))
                        .frame(height: 180)
                        .padding(.bottom, -100)
                    HStack {
                        ActivityButtonsView(store: store)
                    }
                }
            }
            .ignoresSafeArea()
            .padding(.bottom, 40)
        }
    }
    
    /// Builds a `CloudSharingView` with state after processing a share.
    private func shareView(share: CKShare?) -> CloudKitShareView? {
        guard let share else {
            return nil
        }
        
        return CloudKitShareView(share: share)
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
                initialState: Activity.State(activities: activities,
                                             groupedActivities: grouped,
                                             activityHeaderDates: [Date()], activityTilesState: ActivityTiles.State()),
                reducer: Activity()))
    }
}
