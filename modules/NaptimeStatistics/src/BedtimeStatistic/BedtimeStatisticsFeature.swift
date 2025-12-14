//
//  BedtimeStatisticsFeature.swift
//  NaptimeStatistics
//
//  Created by Luca on 2.10.2023.
//


import Foundation
import ComposableArchitecture
import NaptimeKit

public struct BedtimeStatisticsFeature: Reducer {
    
    @Dependency(\.activityService) var activityService
    
    let statisticsService = StatisticsService()
    
    public struct State: Equatable {
        public init(activities: [ActivityModel] = [], timeframe: StatisticsTimeFrame = .week, datapoints: [SleepStatisticDatapoint] = []) {
            self.activities = activities
            self.timeframe = timeframe
            self.datapoints = datapoints
        }

        var activities: [ActivityModel] = []

        var datapoints: [SleepStatisticDatapoint] = []
        var averageNaps: TimeInterval = 0

        @BindingState var timeframe: StatisticsTimeFrame = .week

        // Scroll-related state
        @BindingState var scrollPosition: Date = Date()
        var isScrolledToToday: Bool = true
        var earliestDataDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case reloadStatistics

        case statisticsUpdated(SleepStatisticsResult)

        // Scroll actions
        case scrollPositionChanged(Date)
        case jumpToToday

        // framework actions
        case binding(BindingAction<State>)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.reloadStatistics)

            case .reloadStatistics:
                return .run { [timeframe = state.timeframe] send in
                    // Fetch all activities for unlimited scrolling
                    let activitiesToCompute = await activityService.fetchActivitiesAfter(nil)

                    // Calculate earliest date for chart domain
                    let earliestDate = activitiesToCompute.map(\.startDate).min() ?? Date()

                    async let datapoints = statisticsService.createBedtimeStatisticDatapoints(activitiesToCompute, timeframe: timeframe)
                    async let usualBedtime = statisticsService.usualBedtime(activitiesToCompute, timeframe: timeframe)

                    await send(.statisticsUpdated(.init(
                        sleepDatapoints: datapoints,
                        sleepPerDay: usualBedtime,
                        earliestDate: earliestDate
                    )))
                }

            case .statisticsUpdated(let result):
                state.datapoints = result.sleepDatapoints
                state.averageNaps = result.sleepPerDay
                state.earliestDataDate = result.earliestDate
                return .none

            case .scrollPositionChanged(let newPosition):
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let scrollDay = calendar.startOfDay(for: newPosition)
                let daysDifference = calendar.dateComponents([.day], from: scrollDay, to: today).day ?? 0
                state.isScrolledToToday = daysDifference <= 0
                return .none

            case .jumpToToday:
                state.scrollPosition = Date()
                state.isScrolledToToday = true
                return .none

            case .binding(\.$timeframe):
                state.scrollPosition = Date()
                state.isScrolledToToday = true
                return .send(.reloadStatistics)

            case .binding:
                return .none
            }
        }
    }
}

