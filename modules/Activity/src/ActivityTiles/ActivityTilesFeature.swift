//
//  ActivityTilesFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 8.2.2023.
//

import Foundation
import ComposableArchitecture
#if os(macOS) || os(iOS) || os(tvOS)
import NaptimeKit
#elseif os(watchOS)
import NaptimeKitWatchOS
#endif

public struct ActivityTiles: Reducer {
    
    @Dependency(\.activityService) private var activityService
    
    let activityTilesFactory = ActivityTilesFactory()
    
    public struct State: Equatable {
        public init() {}
        var tiles = IdentifiedArrayOf<ActivityTile>()
    }
    
    public enum Action: Equatable {
        case tileTapped(ActivityTile)
        case tilesUpdated(IdentifiedArrayOf<ActivityTile>)
        case updateTiles([ActivityModel])
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .updateTiles(let activities):
                    return .run { send in
                        let updatedTiles = await activityTilesFactory.buildTiles(activities)
                        await send(.tilesUpdated(updatedTiles))
                    }
                case .tilesUpdated(let activityTiles):
                    state.tiles = activityTiles
                case .tileTapped(let tile):
                    print("Tapped tile \(tile.title)")
            }
            return .none
        }
    }
}

