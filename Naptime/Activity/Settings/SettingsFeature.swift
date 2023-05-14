//
//  SettingsFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 14.5.2023.
//

import ComposableArchitecture

struct SettingsFeature: ReducerProtocol {
    
    struct State: Equatable {
        @BindingState var showLiveAction: Bool
    }
    enum Action: Equatable, BindableAction {
        case shareTapped
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                case .shareTapped:
                    return .none
                case .binding(_):
                    return .none
            }
        }
        BindingReducer()
    }
}
