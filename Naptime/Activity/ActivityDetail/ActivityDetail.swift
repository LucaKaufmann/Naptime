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
    
    struct State: Equatable, Identifiable {
        let id: UUID
        var activity: ActivityModel?
        var intervalSincePreviousActivity: TimeInterval?
    }
    
    enum Action {
        case updateActivity(ActivityModel)
        case deleteActivity(ActivityModel)
        case activityUpdated
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateActivity(let model):
                state.activity = model
                
                return .task {
                    await activityService.updateActivityFor(id: model.id, startDate: model.startDate, endDate: model.endDate, type: model.type)
                    
                    return .activityUpdated
                }
            case .deleteActivity(_):
                state.activity = nil
            default:
                break
            }
            return .none
        }
    }
    
//    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
//        switch action {
//        case .updateActivity(let model):
//            state.activity = model
//        case .deleteActivity(_):
//            state.activity = nil
//        }
//        return .none
//    }
}
