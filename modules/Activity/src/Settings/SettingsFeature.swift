//
//  SettingsFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 14.5.2023.
//

import ComposableArchitecture
import CloudKit
import ActivityKit
import NaptimeKit

public struct SettingsFeature: Reducer {
    
    @Dependency(\.liveActivityService) var liveActivityService
    
    public struct State: Equatable {
        @BindingState var showAsleepLiveAction: Bool
        @BindingState var showAwakeLiveAction: Bool

        
        @PresentationState var shareSheet: ShareSheetFeature.State?
        
        var share: CKShare?
        var lastActivity: ActivityModel?
    }
    public enum Action: Equatable, BindableAction {
        case shareTapped
        case shareCreated(CKShare)
        case handleLiveActivities
        
        case binding(BindingAction<State>)
        case shareSheet(PresentationAction<ShareSheetFeature.Action>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .shareTapped:
                    return .run { send in
                        let shareRecord: CKShare
                        if let storedShare = await PersistenceController.shared.getShareRecord() {
                            shareRecord = storedShare
                        } else {
                            shareRecord = await PersistenceController.shared.share()
                        }

                        await send(.shareCreated(shareRecord))
                    }
                case .shareCreated(let share):
                    state.share = share
                    state.shareSheet = .init(id: UUID())
                    return .none
//                case .binding(\.$showLiveAction):
//                    if #available(iOS 16.1, *) {
//                        UserDefaults.standard.set(state.showLiveAction, forKey: Constants.showLiveActivitiesKey)
//                        if !state.showLiveAction {
//                            Task {
//                                for activity in Activity<NaptimeWidgetAttributes>.activities{
//                                    await activity.end(dismissalPolicy: .immediate)
//                                }
//                            }
//                        } else {
//
//                            if let lastActivity = state.lastActivity {
//                                if lastActivity.endDate == nil {
//                                    if ActivityAuthorizationInfo().areActivitiesEnabled {
//
//                                        let activityAttributes = NaptimeWidgetAttributes(id: lastActivity.id)
//                                        let activityContent = NaptimeWidgetAttributes.ContentState(startDate: lastActivity.startDate, activityState: .asleep)
//
//                                        do {
//                                            let deliveryActivity = try Activity<NaptimeWidgetAttributes>.request(attributes: activityAttributes, contentState: activityContent)
//                                        } catch (let error) {
//                                            print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
//                                        }
//                                    }
//                                }
//                            }
//                        }
//
//                    }
//                    return .none
                case .handleLiveActivities:
                    let lastActivity = state.lastActivity
                    if #available(iOS 16.2, *) {
                        return .run { _ in
                            if #available(iOS 16.2, *) {
                                if let lastActivity {
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
                    } else {
                        return .none
                    }
                case .binding(\.$showAwakeLiveAction):
                    UserDefaults.standard.set(state.showAwakeLiveAction, forKey: Constants.showAwakeLiveActivitiesKey)
                    return .send(.handleLiveActivities)
                case .binding(\.$showAsleepLiveAction):
                    UserDefaults.standard.set(state.showAsleepLiveAction, forKey: Constants.showAsleepLiveActivitiesKey)
                    return .send(.handleLiveActivities)
                case .binding(_):
                    return .none
                case .shareSheet(_):
                    return .none
            }
        }
        .ifLet(\.$shareSheet, action: /Action.shareSheet) {
            ShareSheetFeature()
        }
    }
}
