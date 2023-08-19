//
//  ActivityListAwakeRow.swift
//  Naptime
//
//  Created by Luca Kaufmann on 1.2.2023.
//

import SwiftUI
import ComposableArchitecture

struct ActivityListAwakeRow: View {
    
    let store: Store<ActivityFeature.State, ActivityFeature.Action>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            if !viewStore.activitiesActive {
                if let latestActivity = viewStore.activities.first {
                    if let date = latestActivity.endDate {
                        AwakeRow(interval: Date().timeIntervalSince(date))
                    }
                }
            }
        }
    }
}
