//
//  LiveActivityManager.swift
//  Naptime
//
//  Created by Luca Kaufmann on 6.6.2023.
//

import Foundation
import ComposableArchitecture
import ActivityKit
import NapTimeData

private enum LiveActivityServiceKey: DependencyKey {
    static let liveValue = LiveActivityService()
}

extension DependencyValues {
    var liveActivityService: LiveActivityService {
        get { self[LiveActivityServiceKey.self] }
        set { self[LiveActivityServiceKey.self] = newValue }
    }
}

struct LiveActivityService {
    @available(iOS 16.2, *)
    func startNewLiveActivity(activity: ActivityModel) async {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let activityState: NaptimeActivityState = activity.isActive ? .asleep : .awake

            if let existingActivity = Activity<NaptimeWidgetAttributes>.activities.filter({
                $0.attributes.id == activity.id
            }).first {
                let updatedContentState = NaptimeWidgetAttributes.ContentState(startDate: activity.startDate, activityState: activityState)
                
                await existingActivity.update(using: updatedContentState)
            } else {
                
                let activityAttributes = NaptimeWidgetAttributes(id: activity.id)
                let activityContent = NaptimeWidgetAttributes.ContentState(startDate: activity.startDate, activityState: activityState)
                
                do {
                    let deliveryActivity = try Activity<NaptimeWidgetAttributes>.request(attributes: activityAttributes, contentState: activityContent)
                    print("Starting live activity")
                } catch (let error) {
                    print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
                }
            }
        }
        
    }
    
    @available(iOS 16.2, *)
    func stopLiveActivities() async {
        for activity in Activity<NaptimeWidgetAttributes>.activities{
            await activity.end(dismissalPolicy: .immediate)
        }
    }
}
