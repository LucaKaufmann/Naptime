//
//  ActivityView.swift
//  WatchApp
//
//  Created by Luca on 29.10.2023.
//

import SwiftUI
import ComposableArchitecture
import CloudKit
import DesignSystemWatchOS
import NaptimeKitWatchOS
import NaptimeSettingsWatchOS
import NaptimeStatisticsWatchOS
import ActivityWatchOS


public struct WatchActivityView: View {
    
    @State var activeShare: CKShare?
    
    let store: StoreOf<WatchActivityFeature>
    
    private let minHeight = 0.0
    private let maxHeight = 320.0
    
    public init(store: StoreOf<WatchActivityFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                WatchActivityListView(store: store)
                sleepToggle
            }
            .scrollContentBackground(.hidden)
            .ignoresSafeArea()
            .background(
                NaptimeDesignColors.slate
            )
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
                #else
                WatchActivityButtonsView(store: store)
                #endif
            }
            .ignoresSafeArea()
//            .padding(.bottom, 40)
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

//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        let date = Date()
//        let activities = [ActivityModel(id: UUID(), startDate: date, endDate: nil, type: .sleep)]
//        let grouped: [Date: IdentifiedArrayOf<ActivityDetail.State>] = [date: [ActivityDetail.State(id: UUID(), activity: activities.first)]]
//        ActivityView(
//            store: Store(
//                initialState: ActivityFeature.State(activities: activities,
//                                                    groupedActivities: grouped,
//                                                    activityHeaderDates: [date], activityTilesState: ActivityTiles.State())) { ActivityFeature() })
//    }
//}

