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

class PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let firstActivityDate = dateFormatter.date(from: "2022-12-05 12:00")
        let secondActivityDate = dateFormatter.date(from: "2022-12-05 23:59")
        let thirdActivityDate = dateFormatter.date(from: "2022-12-06 08:00")
        
        let firstActivity = ActivityPersistenceModel(context: viewContext)
        firstActivity.id = UUID()
        firstActivity.startDate = firstActivityDate!
        firstActivity.endDate = Calendar.current.date(byAdding: .init(hour: 8), to: firstActivityDate!)
        firstActivity.activityTypeValue = "sleep"
        
        let secondActivity = ActivityPersistenceModel(context: viewContext)
        secondActivity.id = UUID()
        secondActivity.startDate = secondActivityDate!
        secondActivity.endDate = Calendar.current.date(byAdding: .init(hour: 8), to: secondActivityDate!)
        secondActivity.activityTypeValue = "sleep"
        
        let thirdActivity = ActivityPersistenceModel(context: viewContext)
        thirdActivity.id = UUID()
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

    let container: PersistentContainer

    init(inMemory: Bool = false) {
        container = PersistentContainer(name: "Naptime")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
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

extension PersistenceController {
    
    /// Fetch items on backgound queue
    func fetch<T: NSManagedObject>(model: T.Type,
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
