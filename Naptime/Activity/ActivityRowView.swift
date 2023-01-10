//
//  ActivityRowView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 8.12.2022.
//

import SwiftUI
import NapTimeData

struct ActivityRowView: View {
    
    let activity: ActivityModel
    
    @State var formatter: DateComponentsFormatter = {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute, .second]
          formatter.unitsStyle = .abbreviated
          formatter.zeroFormattingBehavior = .pad
          return formatter
      }()
    
    var body: some View {
        HStack {
            Image(systemName: activity.type.icon)
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                HStack {
                    Text("\(activity.formattedStartDate) - \(activity.formattedEndDate)")
                    if activity.isActive {
                        ProgressView()
                    }
                }
                if activity.isActive {
                    TimerView(isTimerRunning: true, startTime: activity.startDate)
                } else {
                    if let endDate = activity.endDate {
                        Text(formatter.string(from: endDate.timeIntervalSince(activity.startDate)) ?? "")
                            .font(Font.system(size: 12, design: .monospaced))
                    }
                }
            }.padding(.horizontal)
            Spacer()
        }.padding(.horizontal)
    }
}

struct ActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRowView(activity: ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .sleep))
    }
}
