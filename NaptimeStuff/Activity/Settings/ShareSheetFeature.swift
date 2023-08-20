//
//  ShareSheetFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 14.5.2023.
//


import ComposableArchitecture
import CloudKit
import NapTimeData

struct ShareSheetFeature: ReducerProtocol {
    
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        var id: UUID
    }
    enum Action: Equatable {
        case dismissTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                case .dismissTapped:
                    return .fireAndForget {
                        await self.dismiss()
                    }
            }
        }
    }
}
