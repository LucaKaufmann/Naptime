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
                ZStack {
                    BackgroundShape()
                        .foregroundColor(.blue)
                        .frame(width: geometry.size.width, height: geometry.size.height)
//                        .frame(width: 100, height: 100)
                    VStack {
                        Text("Activities")
                        Button(action: {
                            viewStore.send(.startActivity(.sleep))
                        }, label: {
                            Text("Add activity")
                        })
                        ScrollView {
                            ForEach(viewStore.activityHeaderDates, id: \.self) { header in
                                Section(header: ActivitySectionHeaderView(date: header)) {
                                    ForEach(viewStore.groupedActivities[header]!) { activity in
                                        ActivityRowView(activity: activity)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }.ignoresSafeArea()
    }
}

struct BackgroundShape : Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let topLeftCorner = rect.height / 3
        let radius = rect.height*1.5/2
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
        p.addArc(center: CGPoint(x: rect.width/2, y:rect.height), radius: radius, startAngle: .degrees(-125), endAngle: .degrees(-55), clockwise: false)
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
                initialState: Activity.State(activities: activities, groupedActivities: grouped, activityHeaderDates: [Date()]),
                reducer: Activity()))
    }
}
