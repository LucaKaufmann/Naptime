//
//  StatisticsService.swift
//  NaptimeStatistics
//
//  Created by Luca Kaufmann on 22.8.2023.
//

import Foundation
import NaptimeKit

struct StatisticsService {
    func createSleepStatisticDatapoints(_ activities: [ActivityModel], timeframe: StatisticsTimeFrame) async -> [SleepStatisticDatapoint] {
        
        let groupedActivities = await groupActivities(activities, timeframe: timeframe)
        
        var statistics = [SleepStatisticDatapoint]()
        for dateGroup in groupedActivities {
            let date: Date = dateGroup.key
            
            let todaySleepingInterval = dateGroup.value.reduce(0.0) {
                $0 + $1.duration
            }
            
            let hoursSlept = Double(todaySleepingInterval / 3600).round(nearest: 0.5)
            
            statistics.append(.init(date: date, interval: hoursSlept))
        }
        return statistics
    }
    
    func averageSleepAmountPerDay(_ activities: [ActivityModel], timeframe: StatisticsTimeFrame) async -> TimeInterval {
        let groupedActivities = await groupActivities(activities, timeframe: timeframe)
        
        let intervals = groupedActivities
            .values
            .map({
                return $0.reduce(0.0) {
                    $0 + $1.duration
                }
            })
        
        return intervals.average.rounded()
    }
    
    private func groupActivities(_ activities: [ActivityModel], timeframe: StatisticsTimeFrame) async ->  [Date: [ActivityModel]]{
        let calendar = Calendar.current
        var grouped = [Date: [ActivityModel]]()
        for activity in activities {
            let normalizedDate = normalizedDate(activity.startDate, for: timeframe)
            if grouped[normalizedDate] != nil {
                grouped[normalizedDate]!.append(activity)
            } else {
                grouped[normalizedDate] = [activity]
            }
        }
        
        return grouped
    }
    
    private func normalizedDate(_ date: Date, for timeframe: StatisticsTimeFrame) -> Date {
        switch timeframe {
            case .week:
                return Calendar.current.startOfDay(for: date)
            case .month:
                return Calendar.current.startOfDay(for: date)
            case .year:
                return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
        }
    }
}
