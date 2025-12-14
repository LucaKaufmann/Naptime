//
//  BedtimeStatisticsFeatureView.swift
//  NaptimeStatistics
//
//  Created by Luca on 2.10.2023.
//

import SwiftUI
import ComposableArchitecture
import Charts
import NaptimeKit
import DesignSystem

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
            ZStack(alignment: .bottomTrailing) {
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
                    .pickerStyle(.segmented)
                    .padding()
                }

                // Jump to Today button
                if !viewStore.isScrolledToToday {
                    Button {
                        viewStore.send(.jumpToToday)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.right.to.line")
                            Text("Today")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(NaptimeDesignColors.slateInverted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .padding()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewStore.isScrolledToToday)
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
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: visibleDomainLength(for: viewStore.timeframe))
            .chartScrollPosition(x: viewStore.$scrollPosition)
            .chartScrollTargetBehavior(.valueAligned(matching: dateComponentsForSnapping(viewStore.timeframe)))
            .chartXScale(domain: viewStore.earliestDataDate...Date.now)
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
            .onChange(of: viewStore.scrollPosition) { _, newValue in
                viewStore.send(.scrollPositionChanged(newValue))
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

    private func visibleDomainLength(for timeframe: StatisticsTimeFrame) -> Int {
        switch timeframe {
        case .week:
            return 3600 * 24 * 7      // 7 days
        case .month:
            return 3600 * 24 * 30     // 30 days
        case .year:
            return 3600 * 24 * 365    // 365 days
        }
    }

    private func dateComponentsForSnapping(_ timeframe: StatisticsTimeFrame) -> DateComponents {
        switch timeframe {
        case .week, .month:
            return DateComponents(hour: 0)
        case .year:
            return DateComponents(day: 1)
        }
    }

}

#Preview {
    SleepTodayStatisticsFeatureView(store: Store(initialState: SleepTodayStatisticsFeature.State()) {
        SleepTodayStatisticsFeature()
    })
}

