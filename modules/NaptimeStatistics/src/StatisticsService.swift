//
//  StatisticsService.swift
//  NaptimeStatistics
//
//  Created by Luca Kaufmann on 22.8.2023.
//

import Foundation
import NaptimeKit

struct StatisticsService {
    func createSleepStatisticDatapoints(_ activities: [ActivityModel], timeFrame: StatisticsTimeFrame) async -> [SleepStatisticDatapoint] {
        var cutoffDate: Date?
        
        switch timeFrame {
            case .week:
                cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())?.startOf(.day)
            case .month:
                cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())?.startOf(.day)
            case .year:
                cutoffDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())?.startOf(.day)
        }
        var activitiesToCompute: [ActivityModel]
        
        if let cutoffDate {
            activitiesToCompute = activities.filter {
                $0.startDate > cutoffDate
            }
        } else {
            activitiesToCompute = activities
        }
        
        let groupedActivities = await groupActivities(activitiesToCompute)
        
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
    
    func averageSleepAmountPerDay(_ activities: [ActivityModel], timeFrame: StatisticsTimeFrame) async -> TimeInterval {
        var cutoffDate: Date?
        
        switch timeFrame {
            case .week:
                cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())?.startOf(.day)
            case .month:
                cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())?.startOf(.day)
            case .year:
                cutoffDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())?.startOf(.day)
        }
        var activitiesToCompute: [ActivityModel]
        
        if let cutoffDate {
            activitiesToCompute = activities.filter {
                $0.startDate > cutoffDate
            }
        } else {
            activitiesToCompute = activities
        }
        
        let groupedActivities = await groupActivities(activitiesToCompute)
        
        let intervals = groupedActivities
            .values
            .map({
                return $0.reduce(0.0) {
                    $0 + $1.duration
                }
            })
        
        return intervals.average.rounded()
    }
    
    private func groupActivities(_ activities: [ActivityModel]) async ->  [Date: [ActivityModel]]{
        let calendar = Calendar.current
        var grouped = [Date: [ActivityModel]]()
        for activity in activities {
            let normalizedDate = calendar.startOfDay(for: activity.startDate)
            if grouped[normalizedDate] != nil {
                grouped[normalizedDate]!.append(activity)
            } else {
                grouped[normalizedDate] = [activity]
            }
        }
        
        return grouped
    }
}
