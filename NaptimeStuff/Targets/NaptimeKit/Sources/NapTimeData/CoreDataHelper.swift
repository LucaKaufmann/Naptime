//
//  File.swift
//  
//
//  Created by Luca Kaufmann on 2.4.2023.
//

import CoreData
import CloudKit

extension NSPersistentCloudKitContainer {
    func newTaskContext() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.transactionAuthor = TransactionAuthor.app
        return context
    }
    
    /**
     Fetch and return shares in the persistent stores.
     */
    func fetchShares(in persistentStores: [NSPersistentStore]) throws -> [CKShare] {
        var results = [CKShare]()
        for persistentStore in persistentStores {
            do {
                let shares = try fetchShares(in: persistentStore)
                results += shares
            } catch let error {
                print("Failed to fetch shares in \(persistentStore).")
                throw error
            }
        }
        return results
    }
}
