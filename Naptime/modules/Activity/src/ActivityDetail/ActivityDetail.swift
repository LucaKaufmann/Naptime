//
//  ActivityDetail.swift
//  Naptime
//
//  Created by Luca Kaufmann on 13.1.2023.
//

import Foundation
import ComposableArchitecture
import NaptimeKit

public struct ActivityDetail: Reducer {
    
    @Dependency(\.activityService) private var activityService
    
    public struct State: Equatable, Identifiable {
        public let id: UUID
        var activity: ActivityModel?
        var intervalSincePreviousActivity: TimeInterval?
    }
    
    public enum Action: Equatable {
        case updateActivity(ActivityModel)
        case deleteActivity(ActivityModel)
        case activityUpdated
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .updateActivity(let model):
                state.activity = model
                
                return .run { send in
                    await activityService.updateActivityFor(id: model.id, startDate: model.startDate, endDate: model.endDate, type: model.type)
                    
                    await send(.activityUpdated)
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
