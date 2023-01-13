//
//  Nap.swift
//  Naptime
//
//  Created by Luca Kaufmann on 4.12.2022.
//

import Foundation
import ComposableArchitecture
import NapTimeData

private enum ActivityServiceKey: DependencyKey {
    static let liveValue = ActivityService(persistence: PersistenceController.shared)
    static let testValue = ActivityService(persistence: PersistenceController.preview)
}

extension DependencyValues {
  var activityService: ActivityService {
    get { self[ActivityServiceKey.self] }
    set { self[ActivityServiceKey.self] = newValue }
  }
}

struct Activity: ReducerProtocol {
    
    @Dependency(\.activityService) private var activityService
    
    struct State: Equatable {
        var activities: [ActivityModel]
        var groupedActivities: [Date: [ActivityModel]]
        var activityHeaderDates: [Date]
    }
    
    enum Action {
        case startActivity(ActivityType)
        case endActivity(ActivityModel)
        case deleteActivity(Int)
        case activitiesUpdated
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .startActivity(let type):
            let newActivity = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: type)
            
            if let previousActivity = state.activities.last {
                if let index = state.activities.lastIndex(of: previousActivity) {
                    var updatedActivity = previousActivity
                    updatedActivity.endDate = Date()
                    
                    state.activities[index] = updatedActivity
                    Task {
                        await activityService.endActivity(previousActivity.id)
                    }
                }
            }
            
            state.activities.append(newActivity)
            
            return .task {
                await activityService.addActivity(newActivity)
                
                return .activitiesUpdated
            }
        case .deleteActivity(let index):
            state.activities.remove(at: index)
        case .activitiesUpdated:
            state.groupedActivities = groupActivities(state.activities)
            state.activityHeaderDates = activityHeaders(state.groupedActivities)
        case .endActivity(let activity):
            guard activity.endDate == nil else {
                return .none
            }
            
            if let index = state.activities.lastIndex(of: activity) {
                var updatedActivity = activity
                updatedActivity.endDate = Date()
                
                state.activities[index] = updatedActivity
                
                return .task {
                    await activityService.endActivity(activity.id)

                    return .activitiesUpdated
                }
            }
            
            return .none
        }
        
        return .none
    }
    
    private func groupActivities(_ activities: [ActivityModel]) ->  [Date: [ActivityModel]]{
        let calendar = Calendar.current
        var grouped = [Date: [ActivityModel]]()
        for activity in activities {
            let normalizedDate = calendar.startOfDay(for: activity.startDate)
            if let dateActivities = grouped[normalizedDate] {
                print("Append to existing section \(activity)")
                var activitiesForDay = dateActivities
                activitiesForDay.append(activity)
                
                grouped[normalizedDate] = activitiesForDay.sorted(by: { $0.startDate.compare($1.startDate) == .orderedDescending })
            } else {
                print("Create new section for \(activity)")
                grouped[normalizedDate] = [activity]
            }
        }
        
        return grouped
    }
    
    private func activityHeaders(_ activities: [Date: [ActivityModel]]) -> [Date] {
        activities.map({ $0.key }).sorted(by: { $0.compare($1) == .orderedDescending })
    }
}
