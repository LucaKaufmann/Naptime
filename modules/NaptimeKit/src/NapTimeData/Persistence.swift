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

/**
 This app doesn't necessarily post notifications from the main queue.
 */
public extension Notification.Name {
    public static let cdcksStoreDidChange = Notification.Name("cdcksStoreDidChange")
}

struct TransactionAuthor {
    static let app = "app"
}

struct UserInfoKey {
    static let storeUUID = "storeUUID"
    static let transactions = "transactions"
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
        return CloudKitService.container
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
//        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.viewContext.transactionAuthor = TransactionAuthor.app
        
        // Pin the viewContext to the current generation token, and set it to keep itself up to date with local changes.
        container.viewContext.automaticallyMergesChangesFromParent = true
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("###\(#function): Failed to pin viewContext to the current generation:\(error)")
        }
        
        #if InitializeCloudKitSchema
        do {
            try container.initializeCloudKitSchema()
        } catch {
            print("\(#function): initializeCloudKitSchema: \(error)")
        }
        #else
        /**
         Observe the following notifications:
         - The remote change notifications from container.persistentStoreCoordinator.
         - The .NSManagedObjectContextDidSave notifications from any context.
         - The event change notifications from the container.
         */
        NotificationCenter.default.addObserver(self, selector: #selector(storeRemoteChange(_:)),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: container.persistentStoreCoordinator)
        NotificationCenter.default.addObserver(self, selector: #selector(containerEventChanged(_:)),
                                               name: NSPersistentCloudKitContainer.eventChangedNotification,
                                               object: container)
        #endif
        
//        // Observe Core Data remote change notifications.
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(storeRemoteChange(_:)),
//                                               name: .NSPersistentStoreRemoteChange,
//                                               object: container.persistentStoreCoordinator)
    }
    
    /**
     An operation queue for handling history-processing tasks: watching changes, deduplicating tags, and triggering UI updates, if needed.
     */
    lazy var historyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
//        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
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
    
    public func activityTransactions(from notification: Notification) -> [NSPersistentHistoryTransaction] {
        var results = [NSPersistentHistoryTransaction]()
        if let transactions = notification.userInfo?[UserInfoKey.transactions] as? [NSPersistentHistoryTransaction] {
            let entityName = ActivityPersistenceModel.entity().name
            for transaction in transactions where transaction.changes != nil {
                for change in transaction.changes! where change.changedObjectID.entity.name == entityName {
                    results.append(transaction)
                    break // Jump to the next transaction.
                }
            }
        }
        return results
    }
    
    public func mergeTransactions(_ transactions: [NSPersistentHistoryTransaction], to context: NSManagedObjectContext) {
        context.perform {
            for transaction in transactions {
                context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
            }
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


// MARK: - Notification handlers that trigger history processing.
//
public extension PersistenceController {
    
    /**
     Handle .NSPersistentStoreRemoteChange notifications.
     Process persistent history to merge relevant changes to the context, and deduplicate the tags, if necessary.
     */
    @objc
    func storeRemoteChange(_ notification: Notification) {
        guard let storeUUID = notification.userInfo?[NSStoreUUIDKey] as? String,
              [privatePersistentStore.identifier, sharedPersistentStore.identifier].contains(storeUUID) else {
            print("\(#function): Ignore a store remote Change notification because of no valid storeUUID.")
            return
        }
        processHistoryAsynchronously(storeUUID: storeUUID)
    }

    /**
     Handle the container's event change notifications (NSPersistentCloudKitContainer.eventChangedNotification).
     */
    @objc
    func containerEventChanged(_ notification: Notification) {
         guard let value = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey],
              let event = value as? NSPersistentCloudKitContainer.Event else {
            print("\(#function): Failed to retrieve the container event from notification.userInfo.")
            return
        }
        if event.error != nil {
            print("\(#function): Received a persistent CloudKit container event changed notification.\n\(event)")
        }
    }
}

// MARK: - Process persistent historty asynchronously.
//
public extension PersistenceController {
    /**
     Process persistent history, posting any relevant transactions to the current view.
     This method processes the new history since the last history token, and is simply a fetch if there's no new history.
     */
    private func processHistoryAsynchronously(storeUUID: String) {
        historyQueue.addOperation {
            let taskContext = self.container.newTaskContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.performAndWait {
                self.performHistoryProcessing(storeUUID: storeUUID, performingContext: taskContext)
            }
        }
    }
    
    private func performHistoryProcessing(storeUUID: String, performingContext: NSManagedObjectContext) {
        /**
         Fetch the history by the other author since the last timestamp.
        */
        let lastHistoryToken = historyToken(with: storeUUID)
        let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
        let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
        historyFetchRequest.predicate = NSPredicate(format: "author != %@", TransactionAuthor.app)
        request.fetchRequest = historyFetchRequest

        if privatePersistentStore.identifier == storeUUID {
            request.affectedStores = [privatePersistentStore]
        } else if sharedPersistentStore.identifier == storeUUID {
            request.affectedStores = [sharedPersistentStore]
        }

        let result = (try? performingContext.execute(request)) as? NSPersistentHistoryResult
        guard let transactions = result?.result as? [NSPersistentHistoryTransaction] else {
            return
        }
        // print("\(#function): Processing transactions: \(transactions.count).")

        /**
         Post transactions so observers can update the UI, if necessary, even when transactions is empty
         because when a share changes, Core Data triggers a store remote change notification with no transaction.
         */
        let userInfo: [String: Any] = [UserInfoKey.storeUUID: storeUUID, UserInfoKey.transactions: transactions]
        NotificationCenter.default.post(name: .cdcksStoreDidChange, object: self, userInfo: userInfo)
        /**
         Update the history token using the last transaction. The last transaction has the latest token.
         */
        if let newToken = transactions.last?.token {
            updateHistoryToken(with: storeUUID, newToken: newToken)
        }
        
        /**
         Limit to the private store so only owners can deduplicate the tags. Owners have full access to the private database, and so
         don't need to worry about the permissions.
         */
        guard !transactions.isEmpty, storeUUID == privatePersistentStore.identifier else {
            return
        }
        /**
         Deduplicate the new tags.
         This only deduplicates the tags that aren't shared or have the same share.
         */
//        var newTagObjectIDs = [NSManagedObjectID]()
//        let tagEntityName = Tag.entity().name
//
//        for transaction in transactions where transaction.changes != nil {
//            for change in transaction.changes! {
//                if change.changedObjectID.entity.name == tagEntityName && change.changeType == .insert {
//                    newTagObjectIDs.append(change.changedObjectID)
//                }
//            }
//        }
//        if !newTagObjectIDs.isEmpty {
//            deduplicateAndWait(tagObjectIDs: newTagObjectIDs)
//        }
    }
    
    /**
     Track the last history tokens for the stores.
     The historyQueue reads the token when executing operations, and updates it after completing the processing.
     Access this user default from the history queue.
     */
    private func historyToken(with storeUUID: String) -> NSPersistentHistoryToken? {
        let key = "HistoryToken" + storeUUID
        if let data = UserDefaults.standard.data(forKey: key) {
            return  try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: data)
        }
        return nil
    }
    
    private func updateHistoryToken(with storeUUID: String, newToken: NSPersistentHistoryToken) {
        let key = "HistoryToken" + storeUUID
        let data = try? NSKeyedArchiver.archivedData(withRootObject: newToken, requiringSecureCoding: true)
        UserDefaults.standard.set(data, forKey: key)
    }
}

