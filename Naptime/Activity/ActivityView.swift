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
        GeometryReader { geometry in
            WithViewStore(self.store) { viewStore in
                NavigationView {
                    ZStack {
                        Color("ocean")
                            .edgesIgnoringSafeArea(.all)
                        BackgroundShape()
                            .foregroundColor(Color("slate"))
                            .edgesIgnoringSafeArea(.all)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        //                        .frame(width: 100, height: 100)
                        VStack {
                            VStack {
                                Button(action: {
                                    viewStore.send(.startActivity(.sleep))
                                }, label: {
                                    Image(systemName: "plus.app")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color("tomato"))
                                })
                            }
                            .frame(height: max(geometry.size.height / 3 - 40, 0))
                            .padding(.bottom, 40)
                            ScrollView {
                                ForEach(viewStore.activityHeaderDates, id: \.self) { header in
                                    Section(header: ActivitySectionHeaderView(date: header)) {
                                        ForEach(viewStore.groupedActivities[header]!) { activity in
                                            NavigationLink(destination: ActivityDetailView(store: store.scope(state: \.activityDetailState,
                                                                                                              action: Activity.Action.activityDetailAction))) {
                                                ActivityRowView(activity: activity)
                                            }.buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }.edgesIgnoringSafeArea(.vertical)
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
        let grouped: [Date: [ActivityModel]] = [date: activities]
        ActivityView(
            store: Store(
                initialState: Activity.State(activities: activities, groupedActivities: grouped, activityHeaderDates: [Date()], activityDetailState: ActivityDetail.State(activity: activities.first!)),
                reducer: Activity()))
    }
}
