//
//  SleepTodayStatisticsFeature.swift
//  NaptimeStatisticsApp
//
//  Created by Luca Kaufmann on 22.8.2023.
//

import Foundation
import ComposableArchitecture
import NaptimeKit



public struct SleepTodayStatisticsFeature: Reducer {

    public init() {}

    @Dependency(\.activityRepository) var activityRepository

    let statisticsService = StatisticsService()
    
    public struct State: Equatable {
        public init(activities: [ActivityModel] = [], timeframe: StatisticsTimeFrame = .week, datapoints: [SleepStatisticDatapoint] = []) {
            self.activities = activities
            self.timeframe = timeframe
            self.datapoints = datapoints
        }
        
        var activities: [ActivityModel] = []
        
        var datapoints: [SleepStatisticDatapoint] = []
        var averageSleep: TimeInterval = 0
        
        @BindingState var timeframe: StatisticsTimeFrame = .week
    }
    
    public enum Action: Equatable, BindableAction {
        case onAppear
        case reloadStatistics
        
        case statisticsUpdated(SleepStatisticsResult)
        
        // framework actions
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .onAppear:
                    return .send(.reloadStatistics)
                case .reloadStatistics:
                    let fetchActivities = activityRepository.fetch
                    return .run {[timeframe = state.timeframe] send in

                        let cutoffDate: Date?

                        switch timeframe {
                            case .week:
                                cutoffDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())?.startOf(.day)
                            case .month:
                                cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())?.startOf(.day)
                            case .year:
                                cutoffDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())?.startOf(.day)
                        }

                        let query = ActivityQuery(afterDate: cutoffDate)
                        let activitiesToCompute = try await fetchActivities(query)

                        async let datapoints = statisticsService.createSleepStatisticDatapoints(activitiesToCompute, timeframe: timeframe)
                        async let averageSleep = statisticsService.averageSleepAmountPerDay(activitiesToCompute, timeframe: timeframe)
                        await send(.statisticsUpdated(.init(sleepDatapoints: datapoints, sleepPerDay: averageSleep)))
                    } 
                case .statisticsUpdated(let result):
                    state.datapoints = result.sleepDatapoints
                    state.averageSleep = result.sleepPerDay
                    return .none
                case .binding(\.$timeframe):
                    return .send(.reloadStatistics)
                case .binding(_):
                    return .none
            }
        }
    }
}
 
