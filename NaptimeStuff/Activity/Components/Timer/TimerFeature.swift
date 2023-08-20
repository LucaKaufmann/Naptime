//
//  TimerFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 16.2.2023.
//

import Foundation
import ComposableArchitecture

struct TimerFeature: ReducerProtocol {
    
    struct State: Equatable {
        var startDate: Date?
        var isTimerRunning: Bool
    }
    
    enum Action: Equatable {
        case startTimer(Date)
        case stopTimer
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
            case .startTimer(let date):
                state.startDate = date
                state.isTimerRunning = true
                return .none
            case .stopTimer:
                state.isTimerRunning = false
                return .none
        }
    }
}
