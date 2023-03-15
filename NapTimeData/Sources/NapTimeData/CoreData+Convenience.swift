//
//  File.swift
//  
//
//  Created by Luca Kaufmann on 15.3.2023.
//

import Foundation
import CoreData

let appTransactionAuthorName = "Naptime"

/**
 A convenience method for creating background contexts that specify the app as their transaction author.
 */
extension NSPersistentContainer {
    func backgroundContext() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.transactionAuthor = appTransactionAuthorName
        return context
    }
}
