//
//  NapTodayStatisticsFeatureVIew.swift
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

public struct NapTodayStatisticsFeatureView: View {
    
    public init(store: StoreOf<NapTodayStatisticsFeature>) {
        self.store = store
    }
    
    let store: StoreOf<NapTodayStatisticsFeature>
    
    let chartAxisColor = NaptimeDesignColors.slateLight
    
    @State var formatter: DateComponentsFormatter = {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute, .second]
          formatter.unitsStyle = .abbreviated
          formatter.zeroFormattingBehavior = .pad
          return formatter
      }()
    
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("AVG NAPS PER \(viewStore.timeframe == .year ? "MONTH" : "DAY")")
                            .font(.caption)
                        Text(formatter.string(from: viewStore.averageNaps) ?? "")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .foregroundColor(NaptimeDesignColors.slateLight)
                .padding()
                chart

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
                NaptimeDesignColors.tomato.ignoresSafeArea()
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
                .foregroundStyle(NaptimeDesignColors.tomatoInverted.gradient)
            }
            .chartXScale(domain: startDateForTimeFrame(viewStore.timeframe)...Date.now)
            .chartXAxis {
                AxisMarks(values: axisMarkValuesForTimeframe(viewStore.timeframe)) { value in
                    AxisValueLabel(format: formatStyleForTimeframe(viewStore.timeframe))
                        .foregroundStyle(chartAxisColor)
                    AxisGridLine()
                        .foregroundStyle(NaptimeDesignColors.slateLight)
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
    
    private func startDateForTimeFrame(_ timeframe: StatisticsTimeFrame) -> Date {
        let calendar = Calendar.current
        let date: Date
        switch timeframe {
            case .week:
                date = calendar.date(byAdding: .day, value: -6, to: Date.now)!
            case .month:
                let oneMonth = calendar.date(byAdding: .month, value: -1, to: Date.now)!
                date = calendar.date(byAdding: .day, value: -1, to: oneMonth)!
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

