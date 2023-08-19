//
//  LiveActivityPromoFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 19.5.2023.
//


import ComposableArchitecture
import Foundation
import NaptimeKit

struct LiveActivityPromoFeature: Reducer {
        
    struct State: Equatable {
        @BindingState var liveActivitiesEnabled: Bool
    }
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case dismissTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .binding(\.$liveActivitiesEnabled):
                    UserDefaults.standard.set(!state.liveActivitiesEnabled, forKey: Constants.showLiveActivitiesKey)
                    return .none
                case .dismissTapped:
                    return .none
                case .binding(_):
                    return .none
            }
        }
        BindingReducer()
    }
}
