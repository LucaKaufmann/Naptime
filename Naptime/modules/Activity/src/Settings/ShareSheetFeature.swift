//
//  ShareSheetFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 14.5.2023.
//


import ComposableArchitecture
import CloudKit

public struct ShareSheetFeature: Reducer {
    
    @Dependency(\.dismiss) var dismiss
    
    public struct State: Equatable {
        var id: UUID
    }
    public enum Action: Equatable {
        case dismissTapped
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .dismissTapped:
                    return .run { _ in
                        await self.dismiss()
                    }
            }
        }
    }
}
