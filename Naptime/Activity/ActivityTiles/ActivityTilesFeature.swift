//
//  ActivityTilesFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 8.2.2023.
//

import Foundation
import ComposableArchitecture
import NapTimeData

struct ActivityTiles: ReducerProtocol {
    
    @Dependency(\.activityService) private var activityService
    
    let activityTilesFactory = ActivityTilesFactory()
    
    struct State: Equatable {
        var tiles = IdentifiedArrayOf<ActivityTile>()
    }
    
    enum Action: Equatable {
        case tileTapped(ActivityTile)
        case tilesUpdated(IdentifiedArrayOf<ActivityTile>)
        case updateTiles([ActivityModel])
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                case .updateTiles(let activities):
                    return .task {
                        let updatedTiles = await activityTilesFactory.buildTiles(activities)
                        return .tilesUpdated(updatedTiles)
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

