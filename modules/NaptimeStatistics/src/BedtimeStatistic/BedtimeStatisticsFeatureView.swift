//
//  BedtimeStatisticsFeatureView.swift
//  NaptimeStatistics
//
//  Created by Luca on 2.10.2023.
//

import SwiftUI
import ComposableArchitecture
import Charts

#if os(macOS) || os(iOS) || os(tvOS)
import NaptimeKit
import DesignSystem
#elseif os(watchOS)
import NaptimeKitWatchOS
import DesignSystemWatchOS
#endif

public struct BedtimeStatisticsFeatureView: View {
    
    public init(store: StoreOf<BedtimeStatisticsFeature>) {
        self.store = store
    }
    
    let store: StoreOf<BedtimeStatisticsFeature>
    
    let chartAxisColor = NaptimeDesignColors.slateInverted
    
    @State var formatter: DateComponentsFormatter = {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute]
          formatter.unitsStyle = .abbreviated
          formatter.zeroFormattingBehavior = .pad
          return formatter
      }()
    
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("USUAL BEDTIME")
                            .font(.caption)
                        Text(formatter.string(from: viewStore.averageNaps) ?? "")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .foregroundColor(NaptimeDesignColors.slateInverted)
                .padding()
                chart
                Picker("Chart timeframe", selection: viewStore.$timeframe) {
                    ForEach(StatisticsTimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue)
                    }
                }
                .padding()
                #if os(watchOS)
                Picker("Chart timeframe", selection: viewStore.$timeframe) {
                    ForEach(StatisticsTimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue)
                    }
                }
                .padding()
                #else
                Picker("Chart timeframe", selection: viewStore.$timeframe) {
                    ForEach(StatisticsTimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue)
                    }
                }
                .padding()
                .pickerStyle(.segmented)
                #endif

            }
            .background {
                NaptimeDesignColors.sandInverted.ignoresSafeArea()
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    private var chart: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Chart(viewStore.datapoints, id: \.date) {
                BarMark(
                    x: .value("date", $0.date, unit: componentForTimeframe(viewStore.timeframe)),
                    y: .value("duration", $0.interval)
                )
                .accessibilityLabel($0.date.formatted(date: .complete, time: .omitted))
                .accessibilityValue("\($0.interval) sleep")
                .foregroundStyle(NaptimeDesignColors.sand.gradient)
            }
            .chartXScale(domain: startDateForTimeFrame(viewStore.timeframe)...Date.now)
            .chartXAxis {
                AxisMarks(values: axisMarkValuesForTimeframe(viewStore.timeframe)) { value in
                    AxisValueLabel(format: formatStyleForTimeframe(viewStore.timeframe))
                        .foregroundStyle(chartAxisColor)
                    AxisTick()
                        .foregroundStyle(chartAxisColor)
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 14400)) { value in
                    AxisValueLabel {
                        Text("\(formatter.string(from: TimeInterval(value.as(TimeInterval.self) ?? 0)) ?? "")")
                            .foregroundStyle(chartAxisColor)
                    }
                }
            }
        }
    }
    
    private func startDateForTimeFrame(_ timeframe: StatisticsTimeFrame) -> Date {
        let calendar = Calendar.current
        let date: Date
        
//        date = calendar.date(byAdding: .year, value: -1, to: Date.now)!
        switch timeframe {
            case .week:
                date = calendar.date(byAdding: .day, value: -7, to: Date.now)!
            case .month:
                date = calendar.date(byAdding: .month, value: -1, to: Date.now)!
            case .year:
                date = calendar.date(byAdding: .year, value: -1, to: Date.now)!
        }
        
        return date
    }
    
    private func componentForTimeframe(_ timeframe: StatisticsTimeFrame) -> Calendar.Component {
        let component: Calendar.Component
        switch timeframe {
            case .week:
                component = .weekday
            case .month:
                component = .day
            case .year:
                component = .month
        }
        
        return component
    }
    
    private func formatStyleForTimeframe(_ timeframe: StatisticsTimeFrame) -> Date.FormatStyle {
        let style: Date.FormatStyle
        switch timeframe {
            case .week:
                style = .dateTime.weekday()
            case .month:
                style = .dateTime.day()
            case .year:
                style = .dateTime.month()
        }
        
        return style
    }
    
    private func axisMarkValuesForTimeframe(_ timeframe: StatisticsTimeFrame) -> AxisMarkValues {
        let values: AxisMarkValues
        switch timeframe {
            case .week:
                values = .stride(by: .day, count: 1)
            case .month:
                values = .automatic
            case .year:
                values = .stride(by: .month, count: 1)
        }
        
        return values
    }
    
}

#Preview {
    SleepTodayStatisticsFeatureView(store: Store(initialState: SleepTodayStatisticsFeature.State()) {
        SleepTodayStatisticsFeature()
    })
}

