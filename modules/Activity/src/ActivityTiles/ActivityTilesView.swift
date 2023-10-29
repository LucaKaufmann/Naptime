//
//  ActivityTilesView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 10.2.2023.
//

import SwiftUI
import ComposableArchitecture
#if os(macOS) || os(iOS) || os(tvOS)
import NaptimeKit
#elseif os(watchOS)
import NaptimeKitWatchOS
#endif

struct ActivityTilesView: View {
    
    let store: Store<ActivityTiles.State, ActivityTiles.Action>
    
    @ScaledMetric var tileHeight: CGFloat = 110
    @ScaledMetric var tileWidth: CGFloat = 140
    
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .center) {
                    ForEach(viewStore.tiles) { tile in
                        Group {
                            ActivityTileView(tile: tile)
                        }
                        .frame(width: tileWidth, height: tileHeight)
                        .onTapGesture {
                            viewStore.send(.tileTapped(tile))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ActivityTilesView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: ActivityTiles.State()) {
                ActivityTiles()
            }

        let firstActivityStartDate = Date().startOf(.day)
        let firstActivityEndDate = Calendar.current.date(byAdding: .init(hour: 8), to: firstActivityStartDate)
        let secondActivityStartDate = Calendar.current.date(byAdding: .init(hour: 14), to: firstActivityStartDate)!
        let activities = [ActivityModel(id: UUID(), startDate: firstActivityStartDate, endDate: firstActivityEndDate, type: .sleep) ,ActivityModel(id: UUID(), startDate: secondActivityStartDate, endDate: nil, type: .sleep)]
//        let activityState = Activity.State(activities: activities,
//                                           groupedActivities: [:],
//                                           activityHeaderDates: [Date()], activityTilesState: <#ActivityTiles.State#>)
        ActivityTilesView(store: store)
    }
}
