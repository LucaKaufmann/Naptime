//
//  ActivityRowView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 8.12.2022.
//

import SwiftUI

#if os(macOS) || os(iOS) || os(tvOS)
import DesignSystem
import NaptimeKit
#elseif os(watchOS)
import DesignSystemWatchOS
import NaptimeKitWatchOS
#endif

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
            VStack(spacing: 0) {
                Rectangle()
                    .fill(NaptimeDesignColors.ocean)
                    .frame(width: 4, alignment: .center)
                Image(systemName: activity.type.icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(NaptimeDesignColors.slate)
                    )
                Rectangle()
                    .fill(NaptimeDesignColors.ocean)
                    .frame(width: 4, alignment: .center)
            }
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
            Image(systemName: "chevron.right")
        }
        .padding(.horizontal)
        .background(
            NaptimeDesignColors.ocean
                .offset(x: 34)
                .mask(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0)]), startPoint: .leading, endPoint: .trailing)
                )
        )
    }
}

struct ActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRowView(activity: ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: .sleep))
    }
}
