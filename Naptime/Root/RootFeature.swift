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
import NapTimeData

struct Root: ReducerProtocol {
    
    @Dependency(\.activityService) private var activityService

    struct State: Equatable {
        var activityState: Activity.State
    }
    
    enum Action {
        case activityAction(Activity.Action)
        case onAppear
        case loadedActivities(Result<[ActivityModel], Error>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return Future(asyncFunc: {
                    let date = Calendar.current.date(byAdding: .day, value: -7, to: Date())?.startOf(.day)
                    return await activityService.fetchActivitiesAfter(date)
                }).receive(on: DispatchQueue.main)
                  .catchToEffect()
                  .map(Action.loadedActivities)
            case .loadedActivities(let result):
                switch result {
                case .success(let activities):
                    state.activityState.lastActivityDate = activities[safe: 0]?.endDate ?? activities[safe: 0]?.startDate
                    state.activityState.activities = activities
                case .failure(let error):
                    os_log("Failed to load activities %@ ",
                           log: OSLog.persistence,
                           type: .error, error as CVarArg)
                  break
                }
                return .task {
                    return .activityAction(.activitiesUpdated)
                }
                case .activityAction(.refreshActivities):
                    return .send(.onAppear)
            default:
                return .none
            }
            
        }
        Scope(state: \.activityState, action: /Action.activityAction) {
            Activity()
        }
    }
    
    private func fetchActivities() async throws -> [ActivityModel] {
        let persistence = PersistenceController()
        let persistenceModels = try await persistence.fetch(model: ActivityPersistenceModel.self)
         let activityModels = persistenceModels.compactMap({ ActivityModel(persistenceModel: $0) })
        
         return activityModels
    }
    
}
