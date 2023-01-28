//
//  Persistence.swift
//  Naptime
//
//  Created by Luca Kaufmann on 19.11.2022.
//

import CoreData
import OSLog

public enum CoreDataError: Error {
    case fetchError
    case insertBatchError(error: Error)
    case deleteBatchError
    case saveError(error: Error)
    case unknown
}

public class PersistenceController {
    public static let shared = PersistenceController()

    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let firstActivityDate = dateFormatter.date(from: "2022-12-05 12:00")
        let secondActivityDate = dateFormatter.date(from: "2022-12-05 23:59")
        let thirdActivityDate = dateFormatter.date(from: "2022-12-06 08:00")
        
        let firstActivity = ActivityPersistenceModel(context: viewContext)
        firstActivity.id = UUID(uuidString: "7AE07850-6AE1-4DDA-8351-6D157F90496A")!
        firstActivity.startDate = firstActivityDate!
        firstActivity.endDate = Calendar.current.date(byAdding: .init(hour: 8), to: firstActivityDate!)
        firstActivity.activityTypeValue = "sleep"
        
        let secondActivity = ActivityPersistenceModel(context: viewContext)
        secondActivity.id = UUID(uuidString: "271EE86B-188C-4130-AF38-D30D4B7F285E")!
        secondActivity.startDate = secondActivityDate!
        secondActivity.endDate = Calendar.current.date(byAdding: .init(hour: 8), to: secondActivityDate!)
        secondActivity.activityTypeValue = "sleep"
        
        let thirdActivity = ActivityPersistenceModel(context: viewContext)
        thirdActivity.id = UUID(uuidString: "BED4A302-65BD-4D27-99EF-E8E4A4D7934A")!
        thirdActivity.startDate = thirdActivityDate!
        thirdActivity.endDate = Calendar.current.date(byAdding: .init(hour: 8), to: thirdActivityDate!)
        thirdActivity.activityTypeValue = "sleep"
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    public let container: PersistentContainer

    public init(inMemory: Bool = false) {
        guard let modelURL = Bundle.module.url(forResource: "Naptime",
                                               withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }
        
        container = PersistentContainer(name: "Naptime", managedObjectModel: mom)
        let storeUrl = URL.storeURL(for: "group.naptime", databaseName: "NapTime")
        let description = NSPersistentStoreDescription(url: storeUrl)
        container.persistentStoreDescriptions = [description]
        
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }
    
    public lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()
    
    public var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    public func saveViewContext() async throws {
        try await self.container.saveContext()
    }
    
    public func saveBackgroundContext() async throws {
        try await self.container.saveContext(backgroundContext: backgroundContext)
    }
    
    public func destroyDataStore() {
        
        // Get a reference to a NSPersistentStoreCoordinator
        let storeContainer =
        container.persistentStoreCoordinator
        
        // Delete each existing persistent store
        for store in storeContainer.persistentStores {
            guard let url = store.url else {
                return
            }
            try? storeContainer.destroyPersistentStore(
                at: url,
                ofType: store.type,
                options: nil
            )
        }
        
        // Calling loadPersistentStores will re-create the
        // persistent stores
        container.loadPersistentStores { (store, _) in
            os_log("Destroyed data store \n %@ ",
                   log: OSLog.persistence,
                   type: .debug, store.description)
        }
    }
}

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

extension PersistenceController {
    
    /// Fetch items on backgound queue
    public func fetch<T: NSManagedObject>(model: T.Type,
                                   predicate: NSPredicate? = nil,
                                   sortDescriptors: [NSSortDescriptor] = [],
                                   limit: Int = 0,
                                   resultType: NSFetchRequestResultType = .managedObjectResultType) async throws -> [T] {
        
        let fetchRequest = T.fetchRequest()
        fetchRequest.fetchLimit = limit
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.resultType = resultType
        let result = try await perform(fetchRequest: fetchRequest, model: model)
        return result
        
    }
    
    func delete(fetchRequest: NSFetchRequest<NSFetchRequestResult>) async throws {
        
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        request.resultType = NSBatchDeleteRequestResultType.resultTypeObjectIDs
        
        do {
            let result = try backgroundContext.execute(request) as? NSBatchDeleteResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objectIDArray ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable: Any], into: [backgroundContext])
        } catch {
            throw CoreDataError.deleteBatchError
        }
    }
    
    // MARK: Helper
    
    private func perform<T: NSManagedObject>(fetchRequest: NSFetchRequest<NSFetchRequestResult>, model: T.Type) async throws -> [T] {
        try await backgroundContext.perform {
            do {
                let items = (try self.backgroundContext.fetch(fetchRequest) as? [T])
                return items ?? []
            } catch {
                throw CoreDataError.fetchError
            }
        }
    }
    
}

public final class PersistentContainer: NSPersistentCloudKitContainer {
    
    public func saveContext(backgroundContext: NSManagedObjectContext? = nil) async throws {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        try await context.perform {
            do {
                try context.save()
                print("Did save context")
            } catch let error as NSError {
                print("Error: \(error), \(error.userInfo)")
                throw CoreDataError.saveError(error: error)
            }
        }
    }
}
