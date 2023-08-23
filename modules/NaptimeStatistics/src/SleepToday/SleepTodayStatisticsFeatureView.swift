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
import DesignSystem

public struct SleepTodayStatisticsFeatureView: View {
    
    public init(store: StoreOf<SleepTodayStatisticsFeature>) {
        self.store = store
    }
    
    let store: StoreOf<SleepTodayStatisticsFeature>
    
    let chartAxisColor = NaptimeDesignColors.slateLight
    
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
                            .font(.caption)
                        Text(formatter.string(from: viewStore.state) ?? "")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .foregroundColor(NaptimeDesignColors.slateLight)
                .padding()
                chart
            }
            .background {
                NaptimeDesignColors.ocean.ignoresSafeArea()
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
                    x: .value("date", $0.date, unit: .weekday),
                    y: .value("duration", $0.interval)
                )
                .accessibilityLabel($0.date.formatted(date: .complete, time: .omitted))
                .accessibilityValue("\($0.interval) sleep")
                .foregroundStyle(NaptimeDesignColors.oceanInverted.gradient)
            }
            .chartXScale(domain: Calendar.current.date(byAdding: .day, value: -7, to: Date.now)!...Date.now)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) { value in
                    AxisValueLabel(format: .dateTime.weekday())
                        .foregroundStyle(chartAxisColor)
//                    AxisGridLine()
//                        .foregroundStyle(NaptimeDesignColors.slateLight)
                    AxisTick()
                        .foregroundStyle(chartAxisColor)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(centered: true, stroke: StrokeStyle(dash: [1, 2]))
                        .foregroundStyle(chartAxisColor)
                        AxisTick(centered: true, stroke: StrokeStyle(lineWidth: 2))
                          .foregroundStyle(chartAxisColor)
                        AxisValueLabel()
                        .foregroundStyle(chartAxisColor)
                }
            }
//            .frame(height: isOverview ? Constants.previewChartHeight : Constants.detailChartHeight)
        }
    }
    
}

#Preview {
    SleepTodayStatisticsFeatureView(store: Store(initialState: SleepTodayStatisticsFeature.State()) {
        SleepTodayStatisticsFeature()
    })
}
