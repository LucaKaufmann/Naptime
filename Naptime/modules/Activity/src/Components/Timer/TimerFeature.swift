//
//  TimerFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 16.2.2023.
//

import Foundation
import ComposableArchitecture

public struct TimerFeature: Reducer {
    
    public struct State: Equatable {
        var startDate: Date?
        var isTimerRunning: Bool
    }
    
    public enum Action: Equatable {
        case startTimer(Date)
        case stopTimer
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
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
}
