//
//  ActivityPromoFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 19.5.2023.
//

import ComposableArchitecture
import NapTimeData
import Foundation

struct ActivityPromoFeature: ReducerProtocol {
    
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        var id: UUID
        var liveActivity: LiveActivityPromoFeature.State?
    }
    enum Action: Equatable {
        case dismissTapped
        case liveActivityPromo(LiveActivityPromoFeature.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                case .dismissTapped:
                    return .fireAndForget {
                        await self.dismiss()
                    }
                case .liveActivityPromo(.dismissTapped):
                    return .fireAndForget {
                        await self.dismiss()
                    }
                default:
                    return .none
            }
        }.ifLet(\.liveActivity, action: /Action.liveActivityPromo) {
            LiveActivityPromoFeature()
        }
    }
}
