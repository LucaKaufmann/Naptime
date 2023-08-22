//
//  SleepTodayStatisticsFeatureView.swift
//  NaptimeStatistics
//
//  Created by Luca Kaufmann on 22.8.2023.
//

import SwiftUI
import ComposableArchitecture
import Charts
import NaptimeKit

public struct SleepTodayStatisticsFeatureView: View {
    
    public init(store: StoreOf<SleepTodayStatisticsFeature>) {
        self.store = store
    }
    
    let store: StoreOf<SleepTodayStatisticsFeature>
    
    @State var formatter: DateComponentsFormatter = {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute, .second]
          formatter.unitsStyle = .abbreviated
          formatter.zeroFormattingBehavior = .pad
          return formatter
      }()
    
    public var body: some View {
        WithViewStore(self.store, observe: {$0.averageSleep}) { viewStore in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("AVG TIME ASLEEP")
                            .font(.caption2)
                        Text(formatter.string(from: viewStore.state) ?? "")
                    }
                    Spacer()
                }.padding()
                chart
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    private var chart: some View {
        WithViewStore(self.store, observe: { $0.datapoints }) { viewStore in
            Chart(viewStore.state, id: \.date) {
                BarMark(
                    x: .value("Date", $0.date, unit: .day),
                    y: .value("Sleep", $0.interval),
                    width: .automatic
                )
                .accessibilityLabel($0.date.formatted(date: .complete, time: .omitted))
                .accessibilityValue("\($0.interval) sleep")
//                .foregroundStyle(chartColor.gradient)
            }
            .chartXScale(domain: Calendar.current.date(byAdding: .day, value: -7, to: Date.now)!...Date.now)
//            .accessibilityChartDescriptor(self)
            .chartXAxis(.automatic)
            .chartYAxis(.automatic)
//            .frame(height: isOverview ? Constants.previewChartHeight : Constants.detailChartHeight)
        }
    }
    
}

#Preview {
    SleepTodayStatisticsFeatureView(store: Store(initialState: SleepTodayStatisticsFeature.State()) {
        SleepTodayStatisticsFeature()
    })
}
