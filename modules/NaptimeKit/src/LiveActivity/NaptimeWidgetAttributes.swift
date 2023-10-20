//
//  NaptimeWidgetLiveActivity.swift
//  NaptimeWidget
//
//  Created by Luca Kaufmann on 14.5.2023.
//
#if os(iOS)
import ActivityKit
import WidgetKit
import SwiftUI

public struct NaptimeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startDate: Date
        var activityState: NaptimeActivityState
        
        var iconName: String {
            return activityState == .asleep ? "bed.double.circle" : "sun.max"
        }
        
        var titleIconName: String {
            return activityState == .asleep ? "powersleep" : "sun.and.horizon"
        }
    }

    // Fixed non-changing properties about your activity go here!
    var id: UUID
}
#endif
