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
                            VStack {
                                ActivityButtonsView(store: store)
                                ScrollView {
                                    ForEach(viewStore.activityHeaderDates, id: \.self) { header in
                                        Section(header: ActivitySectionHeaderView(date: header)) {
                                            ForEach(viewStore.groupedActivities[header]!, id: \.id) { activity in
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
                                            }
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
        let grouped: [Date: IdentifiedArrayOf<ActivityDetail.State>] = [date: [ActivityDetail.State(id: UUID(), activity: activities.first)]]
        ActivityView(
            store: Store(
                initialState: Activity.State(activities: activities,
                                             groupedActivities: grouped,
                                             activityHeaderDates: [Date()]),
                reducer: Activity()))
    }
}
