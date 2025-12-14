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
import Activity
import NaptimeKit

struct Root: Reducer {

    @Dependency(\.activityRepository) private var activityRepository
    @Dependency(\.uuid) private var uuid
    
    struct State: Equatable {
        var activityState: ActivityFeature.State
        var listeningToStoreChanges: Bool
//        var showLiveActivityPromo: Bool
        
//        @PresentationState var promo: ActivityPromoFeature.State?
    }
    
    enum Action {
        case activityAction(ActivityFeature.Action)
        case onAppear
        case refreshActivities
        case loadedActivities([ActivityModel])
//        case promoAction(PresentationAction<ActivityPromoFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    
//                    if state.showLiveActivityPromo, #available(iOS 16.2, *) {
//                        state.promo = .init(id: uuid(), liveActivity: LiveActivityPromoFeature.State(liveActivitiesEnabled: UserDefaults.standard.bool(forKey: Constants.showLiveActivitiesKey)))
//                        state.showLiveActivityPromo = false
//                        UserDefaults.standard.set(true, forKey: Constants.showLiveActivitiesPromoKey)
//                    }
                    
                    guard !state.listeningToStoreChanges else {
                        print("Already listening to store changes")
                        return .none
                    }
                    state.listeningToStoreChanges = true
                    return .run { send in
                        await send(.refreshActivities)
                        if #available(iOS 16.0, *) {
                            for await _ in NotificationCenter.default.notifications(named: Notification.Name.cdcksStoreDidChange).debounce(for: .seconds(2)) {
                                print("store changed") // This works
                                await send(.refreshActivities)
                            }
                        } else {
                            for await _ in NotificationCenter.default.notifications(named: Notification.Name.cdcksStoreDidChange) {
                                print("store changed") // This works
                                await send(.refreshActivities)
                            }                        }
                    }

                case .refreshActivities:
                    let timeSpan = state.activityState.selectedTimeRange
                    let fetchActivities = activityRepository.fetch

                    return .run { send in
                        let query = ActivityQuery(
                            afterDate: timeSpan == .week
                                ? Calendar.current.date(byAdding: .day, value: -7, to: Date())?.startOf(.day)
                                : nil
                        )
                        let activities = try await fetchActivities(query)

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
//        .ifLet(\.$promo, action: /Action.promoAction) {
//            ActivityPromoFeature()
//        }
        Scope(state: \.activityState, action: /Action.activityAction) {
            ActivityFeature()
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
