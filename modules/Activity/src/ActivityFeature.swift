//
//  Nap.swift
//  Naptime
//
//  Created by Luca Kaufmann on 4.12.2022.
//

import Foundation
import ComposableArchitecture
import ActivityKit
import NaptimeKit
import NaptimeSettings
import NaptimeStatistics

public enum ActivityTimeRange: Int, Equatable {
    case week = 0
    case all = 1
}

public struct ActivityFeature: Reducer {
    
    @Dependency(\.activityService) private var activityService
    @Dependency(\.liveActivityService) private var liveActivityService
    
    public init() {}
    
    public struct ActivityViewState: Equatable {
        
        let groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>]
        let activityHeaderDates: [Date]
    }
    
    public struct State: Equatable {
        public init(activities: [ActivityModel], groupedActivities: [Date : IdentifiedArrayOf<ActivityDetail.State>], activityHeaderDates: [Date], selectedActivityId: ActivityDetail.State.ID? = nil, selectedActivity: ActivityDetail.State? = nil, activityTilesState: ActivityTiles.State, lastActivityDate: Date? = nil, lastActivityTimerState: TimerFeature.State? = nil, isSleeping: Bool = false, selectedTimeRange: ActivityTimeRange = .week, settings: SettingsFeature.State? = nil) {
            self.activities = activities
            self.groupedActivities = groupedActivities
            self.activityHeaderDates = activityHeaderDates
            self.selectedActivityId = selectedActivityId
            self.selectedActivity = selectedActivity
            self.activityTilesState = activityTilesState
            self.lastActivityDate = lastActivityDate
            self.lastActivityTimerState = lastActivityTimerState
            self.isSleeping = isSleeping
            self.selectedTimeRange = selectedTimeRange
            self.settings = settings
        }
        
        public var activities: [ActivityModel]
        var groupedActivities: [Date: IdentifiedArrayOf<ActivityDetail.State>]
        var activityHeaderDates: [Date]
        var selectedActivityId: ActivityDetail.State.ID?
        var selectedActivity: ActivityDetail.State?
        var activityTilesState: ActivityTiles.State
        public var lastActivityDate: Date?
        var lastActivityTimerState: TimerFeature.State?
        
        @BindingState var isSleeping: Bool = false
        @BindingState public var selectedTimeRange: ActivityTimeRange = .week
        
        @PresentationState var settings: SettingsFeature.State?
        @PresentationState var sleepTodaySheet: SleepTodayStatisticsFeature.State?
        @PresentationState var napsTodaySheet: NapTodayStatisticsFeature.State?
        @PresentationState var bedtimeSheet: BedtimeStatisticsFeature.State?
        
        var activitiesActive: Bool {
            return activities.filter({ $0.isActive }).count > 0
        }
        
        func activitiesFor(date: Date) -> IdentifiedArrayOf<ActivityDetail.State> {
            return IdentifiedArrayOf(uniqueElements: groupedActivities[date] ?? [])
        }
    }
    
    public enum Action: Equatable, BindableAction {

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
        case sleepTodaySheet(PresentationAction<SleepTodayStatisticsFeature.Action>)
        case napsTodaySheet(PresentationAction<NapTodayStatisticsFeature.Action>)
        case bedtimeSheet(PresentationAction<BedtimeStatisticsFeature.Action>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .startActivity(let type):
                    let newActivity = ActivityModel(id: UUID(), startDate: Date(), endDate: nil, type: type)
                    
                    state.activities.insert(newActivity, at: 0)
                    return .run { send in
                        await activityService.addActivity(newActivity)

                        await send(.activitiesUpdated)
                    }
                case .deleteActivity(let index):
                    let activity = state.activities[index]
                    state.activities.remove(at: index)
                    return .run { send in
                        await activityService.deleteActivity(activity)
                        
                        await send(.activitiesUpdated)
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
                    let activitiesActive = state.activitiesActive
                    state.isSleeping = activitiesActive
                    let activities = state.activities
                    return .run { send in
                        let groupedActivities = await groupActivities(activities)
                        let activityHeaders = await activityHeaders(groupedActivities)
                        let updatedViewState = ActivityViewState(groupedActivities: groupedActivities, activityHeaderDates: activityHeaders)
                        await send(.activityViewStateUpdated(updatedViewState))
                        await send(.activityTiles(.updateTiles(activities)))
                        
                        if #available(iOS 16.2, *) {
                            if let lastActivity = activities.first {
                                if UserDefaults.standard.bool(forKey: Constants.showAsleepLiveActivitiesKey), lastActivity.isActive {
                                    await liveActivityService.startNewLiveActivity(activity: lastActivity)
                                } else if UserDefaults.standard.bool(forKey: Constants.showAwakeLiveActivitiesKey), !lastActivity.isActive {
                                    await liveActivityService.startNewLiveActivity(activity: lastActivity)
                                } else {
                                    await liveActivityService.stopLiveActivities()
                                }
                            } else {
                                await liveActivityService.stopLiveActivities()
                            }
                        }
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
                        
                        return .run { send in
                            await activityService.endActivity(activity.id)
                            
                            await send(.activitiesUpdated)
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
                    
                    return .run { send in
                        await activityService.endActivities(activities)
                        await send(.activitiesUpdated)
                    }
                case .binding(\.$isSleeping):
                    if state.isSleeping {
                        return .run { send in
                            await send(.startActivity(.sleep))
                        }
                    } else {
                        return .run { send in
                            await send(.endAllActiveActivities)
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
                    state.settings = .init(showAsleepLiveAction: UserDefaults.standard.bool(forKey: Constants.showAsleepLiveActivitiesKey),
                                           showAwakeLiveAction: UserDefaults.standard.bool(forKey: Constants.showAwakeLiveActivitiesKey),
                                           lastActivity: state.activities.first)
                    return .none
                case .activityDetailAction(let action):
                    switch action {
                        case .updateActivity(let activity):
                            guard let index = state.activities.firstIndex(where: { $0.id == activity.id }) else {
                                return .none
                            }
                            
                            state.lastActivityDate = nil
                            state.activities[index] = activity
                            
                            return .run { send in
                                await send(.activitiesUpdated)
                            }
                        case .deleteActivity(let activity):
                            guard let index = state.activities.firstIndex(where: { $0.id == activity.id }) else {
                                return .none
                            }
                            
                            return .run { send in
                                await send(.deleteActivity(index))
                            }
                        default:
                            break
                    }
                case .activityTiles(let action):
                    switch action {
                        case .tileTapped(let tile):
                            switch tile.type {
                                case .sleepToday:
                                    state.sleepTodaySheet = .init(activities: state.activities, timeframe: .week, datapoints: [])
                                case .napsToday:
                                    state.napsTodaySheet = .init(activities: state.activities, timeframe: .week, datapoints: [])
                                case .usualBedtime:
                                    state.bedtimeSheet = .init(activities: state.activities, timeframe: .week, datapoints: [])
                                default:
                                    break
                            }
                        default:
                            break
                    }
                    break
                case .activityTimerAction(_):
                    break
                case .binding(\.$selectedTimeRange):
                    return .send(.refreshActivities)
                case .binding(_) :
                    break
                case .settings(_):
                    break
                case .sleepTodaySheet(_):
                    break
                case .napsTodaySheet(_):
                    break
                case .bedtimeSheet(_):
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
        .ifLet(\.$sleepTodaySheet, action: /Action.sleepTodaySheet) {
            SleepTodayStatisticsFeature()
        }
        .ifLet(\.$napsTodaySheet, action: /Action.napsTodaySheet) {
            NapTodayStatisticsFeature()
        }
        .ifLet(\.$bedtimeSheet, action: /Action.bedtimeSheet) {
            BedtimeStatisticsFeature()
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
