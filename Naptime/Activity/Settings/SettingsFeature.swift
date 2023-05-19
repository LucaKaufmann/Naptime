//
//  SettingsFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 14.5.2023.
//

import ComposableArchitecture
import CloudKit
import NapTimeData
import ActivityKit

struct SettingsFeature: ReducerProtocol {
    
    struct State: Equatable {
        @BindingState var showLiveAction: Bool
        
        @PresentationState var shareSheet: ShareSheetFeature.State?
        
        var share: CKShare?
        var lastActivity: ActivityModel?
    }
    enum Action: Equatable, BindableAction {
        case shareTapped
        case shareCreated(CKShare)
        
        case binding(BindingAction<State>)
        case shareSheet(PresentationAction<ShareSheetFeature.Action>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                case .shareTapped:
                    return .task {
                        let shareRecord: CKShare
                        if let storedShare = await PersistenceController.shared.getShareRecord() {
                            shareRecord = storedShare
                        } else {
                            shareRecord = await PersistenceController.shared.share()
                        }

                        return .shareCreated(shareRecord)
                    }
                case .shareCreated(let share):
                    state.share = share
                    state.shareSheet = .init(id: UUID())
                    return .none
                case .binding(\.$showLiveAction):
                    if #available(iOS 16.1, *) {
                        UserDefaults.standard.set(!state.showLiveAction, forKey: "showLiveAction")
                        if state.showLiveAction {
                            Task {
                                for activity in Activity<NaptimeWidgetAttributes>.activities{
                                    await activity.end(dismissalPolicy: .immediate)
                                }
                            }
                        } else {
                            
                            if let lastActivity = state.lastActivity {
                                if lastActivity.endDate == nil {
                                    if ActivityAuthorizationInfo().areActivitiesEnabled {
                                        
                                        let activityAttributes = NaptimeWidgetAttributes(id: lastActivity.id)
                                        let activityContent = NaptimeWidgetAttributes.ContentState(startDate: lastActivity.startDate)
                                        
                                        do {
                                            let deliveryActivity = try Activity<NaptimeWidgetAttributes>.request(attributes: activityAttributes, contentState: activityContent)
                                            print("Starting live activity")
                                        } catch (let error) {
                                            print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    return .none
                case .binding(_):
                    return .none
                case .shareSheet(_):
                    return .none
            }
        }
        .ifLet(\.$shareSheet, action: /Action.shareSheet) {
            ShareSheetFeature()
        }
        BindingReducer()
    }
}
