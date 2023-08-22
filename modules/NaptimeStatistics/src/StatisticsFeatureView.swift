//
//  StatisticsFeatureView.swift
//  NaptimeStatistics
//
//  Created by Luca Kaufmann on 22.8.2023.
//

import SwiftUI
import ComposableArchitecture

struct StatisticsFeatureView: View {
    
    let store: StoreOf<StatisticsFeature>
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    StatisticsFeatureView(store: Store(initialState: StatisticsFeature.State()) {
        StatisticsFeature()
    })
}
