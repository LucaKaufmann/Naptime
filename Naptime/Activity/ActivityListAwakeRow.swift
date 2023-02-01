//
//  ActivityListAwakeRow.swift
//  Naptime
//
//  Created by Luca Kaufmann on 1.2.2023.
//

import SwiftUI
import ComposableArchitecture

struct ActivityListAwakeRow: View {
    
    let store: Store<Activity.State, Activity.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            if !viewStore.activitiesActive {
                if let latestActivity = viewStore.activities.first {
                    if let date = latestActivity.endDate {
                        if let interval = Date().timeIntervalSince(date) {
                            AwakeRow(interval: interval)
                        }
                    }
                }
            }
        }
    }
}
