////
////  LiveActivityManager.swift
////  Naptime
////
////  Created by Luca Kaufmann on 6.6.2023.
////

import Foundation
import ComposableArchitecture
import ActivityKit

private enum LiveActivityServiceKey: DependencyKey {
    static let liveValue = LiveActivityService()
}

public extension DependencyValues {
    var liveActivityService: LiveActivityService {
        get { self[LiveActivityServiceKey.self] }
        set { self[LiveActivityServiceKey.self] = newValue }
    }
}

public struct LiveActivityService {
    
    public init() {}
    
    @available(iOS 16.2, *)
    public func startNewLiveActivity(activity: ActivityModel) async {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let activityState: NaptimeActivityState = activity.isActive ? .asleep : .awake
            let activityDate: Date = activity.endDate ?? activity.startDate

            if let existingActivity = Activity<NaptimeWidgetAttributes>.activities.filter({
                $0.attributes.id == activity.id
            }).first {
                let updatedContentState = NaptimeWidgetAttributes.ContentState(startDate: activityDate, activityState: activityState)
                
                await existingActivity.update(using: updatedContentState)
            } else {
                
                let activityAttributes = NaptimeWidgetAttributes(id: activity.id)
                let activityContent = NaptimeWidgetAttributes.ContentState(startDate: activityDate, activityState: activityState)
                
                do {
                    let deliveryActivity = try Activity<NaptimeWidgetAttributes>.request(attributes: activityAttributes, contentState: activityContent)
                } catch (let error) {
                    print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
                }
            }
        }
        for activity in Activity<NaptimeWidgetAttributes>.activities.filter({ $0.attributes.id != activity.id }) {
            await activity.end(dismissalPolicy: .immediate)
        }
        
    }
    
    @available(iOS 16.2, *)
    public func stopLiveActivities() async {
        for activity in Activity<NaptimeWidgetAttributes>.activities{
            await activity.end(dismissalPolicy: .immediate)
        }
    }
}
