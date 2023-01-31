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

struct ActivityView: View {
    
    @State var progress: CGFloat = 0
    
    let store: Store<Activity.State, Activity.Action>
    
    private let minHeight = 110.0
    private let maxHeight = 372.0
    
    var body: some View {
        GeometryReader { geometry in
            WithViewStore(self.store) { viewStore in
                NavigationView {
                    ZStack {
                        VStack {
                            Color("slate")
                        }
                        ScalingHeaderScrollView {
                            ZStack {
                                Color("ocean")
                                VStack {
                                    Spacer()
                                    BackgroundShape()
                                        .foregroundColor(Color("slate"))
                                        .edgesIgnoringSafeArea(.all)
                                        .frame(width: geometry.size.width, height: 150)
                                }
                                VStack {
                                    Spacer()
                                    if let recentActivityDate = viewStore.lastActivityDate {
                                        TimerView(label: viewStore.isSleeping ? "Asleep for" : "Awake for",
                                                  fontSize: 18,
                                                  fontDesign: .rounded,
                                                  isTimerRunning: true,
                                                  startTime: recentActivityDate)
                                            .foregroundColor(Color("sand"))
                                            .padding()
                                    }
                                }
                            }
                        } content: {
                            ActivityListView(store: store)
                        }
                        .height(min: minHeight, max: maxHeight)
                        .collapseProgress($progress)
                        sleepToggle
                    }.ignoresSafeArea()
//                    .allowsHeaderGrowth()
//                    ZStack {
//                        Color("ocean")
//                            .edgesIgnoringSafeArea(.all)
//                        BackgroundShape()
//                            .foregroundColor(Color("slate"))
//                            .edgesIgnoringSafeArea(.all)
//                            .frame(width: geometry.size.width, height: geometry.size.height)
//                        VStack {
//                            VStack {
//                                Button(action: {
//                                    viewStore.send(.startActivity(.sleep))
//                                }, label: {
//                                    Image(systemName: "plus.app")
//                                        .resizable()
//                                        .frame(width: 50, height: 50)
//                                        .foregroundColor(Color("tomato"))
//                                })
//                            }
//                            .frame(height: max(geometry.size.height / 3 - 40, 0))
//                            .padding(.bottom, 40)
//                            VStack {
//                                ActivityButtonsView(store: store)
//                                if let recentActivityDate = viewStore.lastActivityDate {
//                                    TimerView(label: viewStore.isSleeping ? "Asleep for" : "Awake for", isTimerRunning: true, startTime: recentActivityDate)
//                                        .foregroundColor(Color("sand"))
//                                }
//                                ScalingHeaderScrollView {
//                                    ZStack {
//                                        Color.white.edgesIgnoringSafeArea(.all)
//                                        Text("Testeirnsotienrsiten")
//
//                                    }
//                                } content: {
//                                    ActivityListView(store: store)
//                                }
////                                ScrollView {
////                                    ActivityListView(store: store)
////                                }
//                            }
//                        }
//                    }
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
                                             activityHeaderDates: [Date()]),
                reducer: Activity()))
    }
}
