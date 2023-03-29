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
    
    public func fetchActivitiesAfter(_ cutoffDate: Date?) async -> [ActivityModel] {
        do {
            var predicate: NSPredicate?
            if let cutoffDate {
                predicate = NSPredicate(format: "startDate > %@", cutoffDate as CVarArg)
            }

            let persistenceModels = try await persistence.fetch(model: ActivityPersistenceModel.self, predicate: predicate, sortDescriptors: [.init(key: "startDate", ascending: false)])
            let activityModels = persistenceModels.compactMap({ ActivityModel(persistenceModel: $0) })
            os_log("Fetched activities: %@ ",
                   log: OSLog.persistence,
                   type: .info, activityModels)
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
    
    public func deleteActivity(_ activity: ActivityModel) async {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ActivityPersistenceModel.entity().name ?? "")
            fetchRequest.predicate = NSPredicate(format: "id == %@", activity.id as CVarArg)
            try await persistence.delete(fetchRequest: fetchRequest)
            os_log("Deleted activity: %@ ",
                   log: OSLog.persistence,
                   type: .info, activity.id as CVarArg)
            await saveContext()
        } catch {
            os_log("Failed to fetch activities: %@ ",
                   log: OSLog.persistence,
                   type: .error, error as CVarArg)
        }
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
        
        activityToUpdate.endDate = endDate
        
        if let type {
            activityToUpdate.activityTypeValue = type.rawValue
        }
        
        await saveContext()
    }
    
    public func endActivities(_ activities: [ActivityModel]) async {
        for activity in activities {
            await endActivity(activity.id)
        }
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
            os_log("Saved background context",
                   log: OSLog.persistence,
                   type: .info)
        } catch {
            os_log("Failed to save background context %@ ",
                   log: OSLog.persistence,
                   type: .error, error as CVarArg)
        }
    }
    
}
