//
//  ActivityPromoFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 19.5.2023.
//

import ComposableArchitecture
import Foundation

struct ActivityPromoFeature: Reducer {
    
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        var id: UUID
        var liveActivity: LiveActivityPromoFeature.State?
    }
    enum Action: Equatable {
        case dismissTapped
        case liveActivityPromo(LiveActivityPromoFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .dismissTapped:
                    return .run { _ in
                        await self.dismiss()
                    }
                case .liveActivityPromo(.dismissTapped):
                    return .run { _ in
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
