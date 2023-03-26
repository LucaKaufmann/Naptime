//
//  Persistence.swift
//  Naptime
//
//  Created by Luca Kaufmann on 19.11.2022.
//

import CoreData
import OSLog
import CloudKit

public enum CoreDataError: Error {
    case fetchError
    case insertBatchError(error: Error)
    case deleteBatchError
    case saveError(error: Error)
    case unknown
}

public class PersistenceController {
    public static let shared = PersistenceController()
    
    private var _privatePersistentStore: NSPersistentStore?
    public var privatePersistentStore: NSPersistentStore {
        return _privatePersistentStore!
    }

    private var _sharedPersistentStore: NSPersistentStore?
    public var sharedPersistentStore: NSPersistentStore {
        return _sharedPersistentStore!
    }

    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let beginningOfHour = Calendar.current.date(bySetting: .minute, value: 0, of: Date())
        let firstActivityDate = Calendar.current.date(byAdding: .hour, value: -17, to: beginningOfHour!)
        let secondActivityDate = Calendar.current.date(byAdding: .hour, value: -5, to: beginningOfHour!)
        let thirdActivityDate = Calendar.current.date(byAdding: .hour, value: -2, to: beginningOfHour!)
        
        let firstActivity = ActivityPersistenceModel(context: viewContext)
        firstActivity.id = UUID(uuidString: "7AE07850-6AE1-4DDA-8351-6D157F90496A")!
        firstActivity.startDate = firstActivityDate!
        firstActivity.endDate = Calendar.current.date(byAdding: .init(hour: 10), to: firstActivityDate!)
        firstActivity.activityTypeValue = "sleep"
        
        let secondActivity = ActivityPersistenceModel(context: viewContext)
        secondActivity.id = UUID(uuidString: "271EE86B-188C-4130-AF38-D30D4B7F285E")!
        secondActivity.startDate = secondActivityDate!
        secondActivity.endDate = Calendar.current.date(byAdding: .init(hour: 1), to: secondActivityDate!)
        secondActivity.activityTypeValue = "sleep"
        
        let thirdActivity = ActivityPersistenceModel(context: viewContext)
        thirdActivity.id = UUID(uuidString: "BED4A302-65BD-4D27-99EF-E8E4A4D7934A")!
        thirdActivity.startDate = thirdActivityDate!
        thirdActivity.endDate = Calendar.current.date(byAdding: .init(hour: 2), to: thirdActivityDate!)
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
    
    public var ckContainer: CKContainer {
      let storeDescription = container.persistentStoreDescriptions.first
      guard let identifier = storeDescription?
        .cloudKitContainerOptions?.containerIdentifier else {
        fatalError("Unable to get container identifier")
      }
      return CKContainer(identifier: identifier)
    }


    public init(inMemory: Bool = false) {
        guard let modelURL = Bundle.module.url(forResource: "Naptime",
                                               withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }
        
        container = PersistentContainer(name: "Naptime", managedObjectModel: mom)
        let privateStoreDescription = container.persistentStoreDescriptions.first!
        let storesURL = URL.storeURL(for: "group.naptime")
        privateStoreDescription.url = storesURL.appendingPathComponent("NapTime.sqlite")
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        //Add Shared Database
        let sharedStoreURL = storesURL.appendingPathComponent("shared.sqlite")
        guard let sharedStoreDescription = privateStoreDescription.copy() as? NSPersistentStoreDescription else {
            fatalError("Copying the private store description returned an unexpected value.")
        }
        sharedStoreDescription.url = sharedStoreURL
        
        if !inMemory {
            let containerIdentifier = privateStoreDescription.cloudKitContainerOptions!.containerIdentifier
            let sharedStoreOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            sharedStoreOptions.databaseScope = .shared
            sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
        } else {
            privateStoreDescription.cloudKitContainerOptions = nil
            sharedStoreDescription.cloudKitContainerOptions = nil
            privateStoreDescription.url = URL(fileURLWithPath: "/dev/null")
            sharedStoreDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.persistentStoreDescriptions.append(sharedStoreDescription)
    
        container.loadPersistentStores(completionHandler: { (loadedStoreDescription, error) in
            if let loadError = error as NSError? {
                fatalError("###\(#function): Failed to load persistent stores:\(loadError)")
            } else if let cloudKitContainerOptions = loadedStoreDescription.cloudKitContainerOptions {
                if .private == cloudKitContainerOptions.databaseScope {
                    self._privatePersistentStore = self.container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescription.url!)
                } else if .shared == cloudKitContainerOptions.databaseScope {
                    self._sharedPersistentStore = self.container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescription.url!)
                }
            }
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.transactionAuthor = appTransactionAuthorName
        
        // Pin the viewContext to the current generation token, and set it to keep itself up to date with local changes.
        container.viewContext.automaticallyMergesChangesFromParent = true
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("###\(#function): Failed to pin viewContext to the current generation:\(error)")
        }
        
//        // Observe Core Data remote change notifications.
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(storeRemoteChange(_:)),
//                                               name: .NSPersistentStoreRemoteChange,
//                                               object: container.persistentStoreCoordinator)
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
    static func storeURL(for appGroup: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer
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
