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
    
    @Dependency(\.activityService) var activityService
    
    let statisticsService = StatisticsService()
    
    public struct State: Equatable {
        public init(activities: [ActivityModel] = [], timeframe: StatisticsTimeFrame = .week, datapoints: [SleepStatisticDatapoint] = []) {
            self.activities = activities
            self.timeframe = timeframe
            self.datapoints = datapoints
        }
        
        var activities: [ActivityModel] = []
        var timeframe: StatisticsTimeFrame = .week
        var datapoints: [SleepStatisticDatapoint] = []
        var averageSleep: TimeInterval = 0
    }
    
    public enum Action: Equatable {
        case onAppear
        case datapointsUpdated([SleepStatisticDatapoint])
        case averageSleepUpdated(TimeInterval)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    return .run {[activities = state.activities, timeframe = state.timeframe] send in
                        let activities = await activityService.fetchActivitiesAfter(nil)
                        async let datapoints = statisticsService.createSleepStatisticDatapoints(activities, timeFrame: timeframe)
                        async let averageSleep = statisticsService.averageSleepAmountPerDay(activities, timeFrame: timeframe)
                        await send(.datapointsUpdated(datapoints))
                        await send(.averageSleepUpdated(averageSleep))
                    }
                case .datapointsUpdated(let datapoints):
                    state.datapoints = datapoints
                    return .none
                case .averageSleepUpdated(let interval):
                    state.averageSleep = interval
                    return .none
            }
            return .none
        }
    }
}
 
