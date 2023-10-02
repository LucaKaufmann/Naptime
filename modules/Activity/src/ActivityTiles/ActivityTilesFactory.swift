//
//  ActivityTilesFactory.swift
//  Naptime
//
//  Created by Luca Kaufmann on 12.2.2023.
//

import Foundation
import ComposableArchitecture
import NaptimeKit

struct ActivityTilesFactory {
    
    var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    func buildTiles(_ activities: [ActivityModel]) async -> IdentifiedArrayOf<ActivityTile> {
        var todayActivities = activities.filter {
            let date = $0.endDate ?? Date()
            return date.isCurrentDay() || $0.startDate.isCurrentDay()
        }
        
        for (index, element) in todayActivities.enumerated() {
            if !element.startDate.isCurrentDay() {
                todayActivities[index] = ActivityModel(id: element.id, startDate: Calendar.current.startOfDay(for: Date()), endDate: element.endDate, type: element.type)
            }
        }
        
        /// Sleep tile
        let todaySleepingInterval = todayActivities.reduce(0.0) {
            $0 + $1.duration
        }
        
        let todaySleepingTile = ActivityTile(id: UUID(), title: "Sleep today", subtitle: "\(formatter.string(from: todaySleepingInterval) ?? "")", type: .sleepToday)
        
        /// Nap tile
        let napsToday = todayActivities.filter {
            $0.duration < 4*3600
        }
        
        let napDurationToday = napsToday.reduce(0.0) {
            $0 + $1.duration
        }
        
        let napsTodayTile = ActivityTile(id: UUID(), title: "Naps today", subtitle: "\(formatter.string(from: napDurationToday) ?? "")", type: .napsToday)
        
        
        
        
        /// Average bedtime tile
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let bedtimeIntervals = activities
            .filter { $0.duration >= 4*3600 }
            .map {
                let interval = Int($0.startDate.timeIntervalSince(Calendar.current.startOfDay(for: $0.startDate)))
                if interval < 12*3600 {
                    return interval + 24*3600
                } else {
                    return interval
                }
            }
        
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let averageTime = startOfDay.addingTimeInterval(bedtimeIntervals.median() ?? 0)
        let averageTimeString = bedtimeIntervals.count > 0 ? formatter.string(from: averageTime) : "-"
        let averageBedtimeTile = ActivityTile(id: UUID(), title: "Usual bedtime", subtitle: averageTimeString, type: .usualBedtime)
        
        return IdentifiedArrayOf(uniqueElements: [todaySleepingTile, napsTodayTile, averageBedtimeTile])
    }
}
