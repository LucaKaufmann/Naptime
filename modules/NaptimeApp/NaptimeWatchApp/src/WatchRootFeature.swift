//
//  RootFeature.swift
//  Naptime
//
//  Created by Luca Kaufmann on 30.11.2022.
//

import ComposableArchitecture
import Combine
import Foundation
import os.log
import AsyncAlgorithms
import ActivityWatchOS
import NaptimeKitWatchOS

struct WatchRootFeature: Reducer {
    
    @Dependency(\.activityService) private var activityService
    @Dependency(\.uuid) private var uuid
    
    struct State: Equatable {
        var activityState: WatchActivityFeature.State
        var listeningToStoreChanges: Bool
    }
    
    enum Action {
        case activityAction(WatchActivityFeature.Action)
        case onAppear
        case refreshActivities
        case loadedActivities([ActivityModel])
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    
                    guard !state.listeningToStoreChanges else {
                        print("Already listening to store changes")
                        return .none
                    }
                    state.listeningToStoreChanges = true
                    return .run { send in
                        await send(.refreshActivities)
//                        if #available(iOS 16.0, *) {
                            for await _ in NotificationCenter.default.notifications(named: Notification.Name.cdcksStoreDidChange).debounce(for: .seconds(2)) {
                                await send(.refreshActivities)
                            }
//                        } else {
//                            for await _ in NotificationCenter.default.notifications(named: Notification.Name.cdcksStoreDidChange) {
//                                print("store changed") // This works
//                                await send(.refreshActivities)
//                            }                        }
                    }

                case .refreshActivities:
                    let timeSpan = state.activityState.selectedTimeRange
                    
                    return .run { send in
                        let date: Date? = timeSpan == .week ? Calendar.current.date(byAdding: .day, value: -7, to: Date())?.startOf(.day) : nil
                         let activities = await activityService.fetchActivitiesAfter(date)
                        
                        await send(.loadedActivities(activities))
                    }
                case .loadedActivities(let activities):
                    state.activityState.lastActivityDate = activities[safe: 0]?.endDate ?? activities[safe: 0]?.startDate
                    state.activityState.activities = activities
                    return .run { send in
                        await send(.activityAction(.activitiesUpdated))
                    }
                case .activityAction(.refreshActivities):
                    return .send(.refreshActivities)
                default:
                    return .none
            }
            
        }
        Scope(state: \.activityState, action: /Action.activityAction) {
            WatchActivityFeature()
        }
    }
    
    private func fetchActivities() async throws -> [ActivityModel] {
        let persistence = PersistenceController.shared
        let persistenceModels = try await persistence.fetch(model: ActivityPersistenceModel.self)
        let activityModels = persistenceModels.compactMap({ ActivityModel(persistenceModel: $0) })
        
        return activityModels
    }
    
    private func processStoreChangeNotification(_ notification: Notification) {
        let transactions = PersistenceController.shared.activityTransactions(from: notification)
        if !transactions.isEmpty {
            PersistenceController.shared.mergeTransactions(transactions, to: PersistenceController.shared.viewContext)
        }
    }
    
    
}
