//
//  StatisticsFeature.swift
//  NaptimeStatistics
//
//  Created by Luca Kaufmann on 22.8.2023.
//

import Foundation
import ComposableArchitecture

public struct StatisticsFeature: Reducer {
    
    public init() {}
    
    public struct State: Equatable {
        
    }
    
    public enum Action: Equatable {
        
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
