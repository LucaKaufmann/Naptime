//
//  ActivityService.swift
//  Naptime
//
//  Created by Luca Kaufmann on 6.12.2022.
//

import Foundation
import CoreData
import OSLog

public struct ActivityService {
    let persistence: PersistenceController
    
    public init(persistence: PersistenceController) {
        self.persistence = persistence
    }
    
    public func fetchActivities() async -> [ActivityModel] {
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
    
    public func addActivity(_ newActivity: ActivityModel) async {
        let newPersistenceActivity = ActivityPersistenceModel(context: persistence.backgroundContext)
        newPersistenceActivity.id = newActivity.id
        newPersistenceActivity.startDate = newActivity.startDate
        newPersistenceActivity.endDate = newActivity.endDate
        newPersistenceActivity.activityTypeValue = newActivity.type.rawValue
        
        await saveContext()
    }
    
    public func updateActivityFor(id: UUID, startDate: Date? = nil, endDate: Date? = nil, type: ActivityType? = nil) async {
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
    
    public func endActivity(_ id: UUID) async {
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
