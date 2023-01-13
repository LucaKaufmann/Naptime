//
//  ActivityDetail.swift
//  Naptime
//
//  Created by Luca Kaufmann on 13.1.2023.
//

import Foundation
import ComposableArchitecture
import NapTimeData

struct ActivityDetail: ReducerProtocol {
    
    @Dependency(\.activityService) private var activityService
    
    struct State: Equatable {
        var activity: ActivityModel?
    }
    
    enum Action {
        case updateActivity(ActivityModel)
        case deleteActivity
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .updateActivity(let model):
            break
        case .deleteActivity:
            break
        }
        return .none
    }
}
