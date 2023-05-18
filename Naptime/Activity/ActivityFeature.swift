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
//        static let liveValue = ActivityService(persistence: PersistenceController.preview)
    static let testValue = ActivityService(persistence: PersistenceController.preview)
    static let previewValue = ActivityService(persistence: PersistenceController.preview)
    
}

extension DependencyValues {
    var activityService: ActivityService {
        get { self[ActivityServiceKey.self] }
        set { self[ActivityServiceKey.self] = newValue }
    }
}

enum ActivityTimeRange: Int, Equatable {
    case week = 0
    case all = 1
}

struct ActivityFeature: ReducerProtocol {
    
    @Dependency(\.activityService) private var activityService
    
    internal struct ActivityViewState: Equatable {
        let groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>]
        let activityHeaderDates: [Date]
    }
    
    struct State: Equatable {
        var activities: [ActivityModel]
        var groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>]
        var activityHeaderDates: [Date]
        var selectedActivityId: ActivityDetail.State.ID?
        var selectedActivity: ActivityDetail.State?
        var activityTilesState: ActivityTiles.State
        var lastActivityDate: Date?
        var lastActivityTimerState: TimerFeature.State?
        
        @BindingState var isSleeping: Bool = false
        @BindingState var selectedTimeRange: ActivityTimeRange = .week
        @BindingState var showShareSheet: Bool = false
        
        @PresentationState var settings: SettingsFeature.State?
        
        var activitiesActive: Bool {
            return activities.filter({ $0.isActive }).count > 0
        }
        
        func activitiesFor(date: Date) -> IdentifiedArrayOf<ActivityDetail.State> {
            return IdentifiedArrayOf(uniqueElements: groupedActivities[date] ?? [])
        }
    }
    
    enum Action: Equatable, BindableAction {

        case startActivity(ActivityType)
        case endActivity(ActivityModel)
        case endAllActiveActivities
        case binding(BindingAction<State>)
        case deleteActivity(Int)
        case activitiesUpdated
        case activityViewStateUpdated(ActivityViewState)
        case activityDetailAction(ActivityDetail.Action)
        case setSelectedActivityId(ActivityModel.ID?)
        case activityTimerAction(TimerFeature.Action)
        case activityTiles(ActivityTiles.Action)
        case settingsButtonTapped
        case refreshActivities
        
        case settings(PresentationAction<SettingsFeature.Action>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .startActivity(let type):
                    let newActivity = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: type)
                    
                    state.activities.insert(newActivity, at: 0)
                    return .task {
                        await activityService.addActivity(newActivity)
                        
                        return .activitiesUpdated
                    }
                case .deleteActivity(let index):
                    let activity = state.activities[index]
                    state.activities.remove(at: index)
                    return .task {
                        await activityService.deleteActivity(activity)
                        
                        return .activitiesUpdated
                    }
                case .refreshActivities:
                    return .none
                case .activitiesUpdated:
                    state.lastActivityDate = state.activities[safe: 0]?.endDate ?? state.activities[safe: 0]?.startDate
                    if let lastActivityDate = state.activities[safe: 0]?.endDate ?? state.activities[safe: 0]?.startDate {
                        state.lastActivityTimerState = TimerFeature.State(startDate: lastActivityDate, isTimerRunning: true)
                    } else {
                        state.lastActivityTimerState = nil
                    }
                    state.isSleeping = state.activitiesActive
                    let activities = state.activities
                    return .run { send in
                        let groupedActivities = await groupActivities(activities)
                        let activityHeaders = await activityHeaders(groupedActivities)
                        let updatedViewState = ActivityViewState(groupedActivities: groupedActivities, activityHeaderDates: activityHeaders)
                        await send(.activityViewStateUpdated(updatedViewState))
                        await send(.activityTiles(.updateTiles(activities)))
                    }
                case .activityViewStateUpdated(let viewState):
                    state.groupedActivities = viewState.groupedActivities
                    state.activityHeaderDates = viewState.activityHeaderDates
                    return .none
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
                case .endAllActiveActivities:
                    let activities = state.activities.filter({ $0.isActive })
                    for activity in activities {
                        guard let index = state.activities.firstIndex(of: activity) else {
                            continue
                        }
                        var updatedActivity = activity
                        updatedActivity.endDate = Date()
                        
                        state.activities[index] = updatedActivity
                    }
                    
                    return .task {
                        await activityService.endActivities(activities)
                        
                        return .activitiesUpdated
                    }
                case .binding(\.$isSleeping):
                    if state.isSleeping {
                        return .task {
                            return .startActivity(.sleep)
                        }
                    } else {
                        return .task {
                            return .endAllActiveActivities
                        }
                    }
                case let .setSelectedActivityId(.some(id)):
                    state.selectedActivityId = id
                    if let activity = state.activities.first(where: { $0.id == id }) {
                        state.selectedActivity = ActivityDetail.State(id: activity.id, activity: activity)
                    }
                    return .none
                    
                case .setSelectedActivityId(nil):
                    state.selectedActivityId = nil
                    return .none
                case .settingsButtonTapped:
                    state.settings = .init(showLiveAction: true)
                    return .none
                case .activityDetailAction(let action):
                    switch action {
                        case .updateActivity(let activity):
                            guard let index = state.activities.firstIndex(where: { $0.id == activity.id }) else {
                                return .none
                            }
                            
                            state.lastActivityDate = nil
                            state.activities[index] = activity
                            
                            return .task {
                                return .activitiesUpdated
                            }
                        case .deleteActivity(let activity):
                            guard let index = state.activities.firstIndex(where: { $0.id == activity.id }) else {
                                return .none
                            }
                            
                            return .task {
                                return .deleteActivity(index)
                            }
                        default:
                            break
                    }
                case .activityTiles(_):
                    break
                case .activityTimerAction(_):
                    break
                case .binding(\.$selectedTimeRange):
                    return .send(.refreshActivities)
                case .binding(_) :
                    break
                case .settings(_):
                    break
            }
            
            return .none
            
        }
        .ifLet(\.selectedActivity, action: /Action.activityDetailAction) {
            ActivityDetail()
        }
        .ifLet(\.lastActivityTimerState, action: /Action.activityTimerAction) {
            TimerFeature()
        }
        .ifLet(\.$settings, action: /Action.settings) {
            SettingsFeature()
          }
        Scope(state: \.activityTilesState, action: /Action.activityTiles) {
            ActivityTiles()
        }
    }
    
    private func groupActivities(_ activities: [ActivityModel]) async ->  [Date: IdentifiedArrayOf<ActivityDetail.State>]{
        let calendar = Calendar.current
        var grouped = [Date: IdentifiedArrayOf<ActivityDetail.State>]()
        for (index, activity) in activities.enumerated() {
            let normalizedDate = calendar.startOfDay(for: activity.startDate)
            if grouped[normalizedDate] != nil {
                var activityDetailState = ActivityDetail.State(id: activity.id, activity: activity)
                if let previousActivityDate = activities[safe: index+1]?.endDate {
                    let difference = activity.startDate.timeIntervalSince(previousActivityDate)
                    activityDetailState.intervalSincePreviousActivity = difference
                }
                
                grouped[normalizedDate]!.append(activityDetailState)
            } else {
                var activityDetailState = ActivityDetail.State(id: activity.id, activity: activity)
                if let previousActivityDate = activities[safe: index+1]?.endDate {
                    let difference = activity.startDate.timeIntervalSince(previousActivityDate)
                    activityDetailState.intervalSincePreviousActivity = difference
                }
                grouped[normalizedDate] = [activityDetailState]
            }
        }
        
        return grouped
    }
    
    private func activityHeaders(_ activities: [Date: IdentifiedArrayOf<ActivityDetail.State>]) async -> [Date] {
        activities.map({ $0.key }).sorted(by: { $0.compare($1) == .orderedDescending })
    }
    
    private func createShare() async {
        //      do {
        //        let (_, share, _) =
        //        try await stack.persistentContainer.share([destination], to: nil)
        //        share[CKShare.SystemFieldKey.title] = destination.caption
        //        self.share = share
        //      } catch {
        //        print("Failed to create share")
        //      }
    }
    
}
