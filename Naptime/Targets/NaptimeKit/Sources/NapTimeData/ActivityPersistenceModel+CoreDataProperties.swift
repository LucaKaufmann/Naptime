//
//  ActivityPersistenceModel+CoreDataProperties.swift
//  Naptime
//
//  Created by Luca Kaufmann on 6.12.2022.
//
//

import Foundation
import CoreData


extension ActivityPersistenceModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityPersistenceModel> {
        return NSFetchRequest<ActivityPersistenceModel>(entityName: "ActivityPersistenceModel")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var activityTypeValue: String?

}

extension ActivityPersistenceModel : Identifiable {

}
