//
//  ActivityService.swift
//  Naptime
//
//  Created by Luca Kaufmann on 6.12.2022.
//

import Foundation
import CoreData
import OSLog
import ComposableArchitecture

private enum ActivityServiceKey: DependencyKey {
    static let liveValue = ActivityService(persistence: PersistenceController.preview)
    static let testValue = ActivityService(persistence: PersistenceController.preview)
}

extension DependencyValues {
  var activityService: ActivityService {
    get { self[ActivityServiceKey.self] }
    set { self[ActivityServiceKey.self] = newValue }
  }
}

struct ActivityService {
    let persistence: PersistenceController
    
    func fetchActivities() async -> [ActivityModel] {
        do {
            let persistenceModels = try await persistence.fetch(model: ActivityPersistenceModel.self, sortDescriptors: [.init(key: "startDate", ascending: true)])
            let activityModels = persistenceModels.compactMap({ ActivityModel(persistenceModel: $0) })
            
            return activityModels
        } catch {
            os_log("Failed to fetch activities: %@ ",
                   log: OSLog.persistence,
                   type: .error, error as CVarArg)
            return []
        }
    }
    
    func addActivity(_ newActivity: ActivityModel) async {
        let newPersistenceActivity = ActivityPersistenceModel(context: persistence.backgroundContext)
        newPersistenceActivity.id = newActivity.id
        newPersistenceActivity.startDate = newActivity.startDate
        newPersistenceActivity.endDate = newActivity.endDate
        newPersistenceActivity.activityTypeValue = newActivity.type.rawValue
        
        await saveContext()
    }
    
    func updateActivityFor(id: UUID, startDate: Date? = nil, endDate: Date? = nil, type: ActivityType? = nil) async {
        guard let activityToUpdate = await fetchActivityFor(id: id) else {
            os_log("Unable to update activity for ID %@",
                   log: OSLog.persistence,
                   type: .error, id as CVarArg)
            return
        }
        
        if let startDate {
            activityToUpdate.startDate = startDate
        }
        
        if let endDate {
            activityToUpdate.endDate = endDate
        }
        
        if let type {
            activityToUpdate.activityTypeValue = type.rawValue
        }
        
        await saveContext()
    }
    
    func endActivity(_ id: UUID) async {
        await updateActivityFor(id: id, endDate: Date())
    }
    
    private func fetchActivityFor(id: UUID) async -> ActivityPersistenceModel? {
        do {
            return try await persistence.fetch(model: ActivityPersistenceModel.self, predicate: NSPredicate(format: "id == %@", id as CVarArg)).first
        } catch {
            os_log("Failed to fetch activity for ID %@: %@ ",
                   log: OSLog.persistence,
                   type: .error, id as CVarArg, error as CVarArg)
            return nil
        }
    }
    
    private func saveContext() async {
        do {
            try await persistence.saveBackgroundContext()
        } catch {
            os_log("Failed to save background context %@ ",
                   log: OSLog.persistence,
                   type: .error, error as CVarArg)
        }
    }
    
}
