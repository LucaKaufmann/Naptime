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
    
    var formatter: DateComponentsFormatter = {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = [.hour, .minute, .second]
          formatter.unitsStyle = .abbreviated
          formatter.zeroFormattingBehavior = .pad
          return formatter
      }()
    
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
                        let updatedTiles = await updateTilesFor(activities)
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
    
    func updateTilesFor(_ activities: [ActivityModel]) async -> IdentifiedArrayOf<ActivityTile> {
        let todayActivities = activities.filter {
            let date = $0.endDate ?? Date()
            return date.isCurrentDay() || $0.startDate.isCurrentDay()
        }
        let todaySleepingInterval = todayActivities.reduce(0.0) {
            $0 + $1.duration
        }
        
        let todaySleepingTile = ActivityTile(id: UUID(), title: "Today asleep", subtitle: "\(formatter.string(from: todaySleepingInterval) ?? "")")
        
        return IdentifiedArrayOf(uniqueElements: [todaySleepingTile])
    }
}

