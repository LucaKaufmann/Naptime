//
//  NapModel.swift
//  Naptime
//
//  Created by Luca Kaufmann on 4.12.2022.
//

import Foundation

public enum ActivityType: String, Equatable {
    case sleep = "sleep"
    case tummyTime = "Tummy time"
    
    public var icon: String {
        switch self {
        case .sleep:
            return "bed.double.circle"
        case .tummyTime:
            return ""
        }
    }
}

public struct ActivityModel: Equatable, Identifiable {
    public let id: UUID
    
    public var startDate: Date
    public var endDate: Date?
    public var type: ActivityType
    public var formattedStartDate: String
    public var formattedEndDate: String
    
    public var duration: TimeInterval {
        if endDate == nil {
            return Date().timeIntervalSince(startDate)
        } else {
            return endDate!.timeIntervalSince(startDate)
        }
    }
    
    public var isActive: Bool {
        return endDate == nil
    }
    
//    public var formattedStartDate: String {
//        return formattedDate(startDate)
//    }
//
//    public var formattedEndDate: String {
//        guard let endDate else {
//            return ""
//        }
//        return formattedDate(endDate)
//    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = calendar.isDateInToday(date) ? "HH:mm" : "E HH:mm"
        return dateFormatter.string(from: date)
    }
    
    public init(id: UUID, startDate: Date, endDate: Date?, type: ActivityType) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = calendar.isDateInToday(startDate) ? "HH:mm" : "E HH:mm"
        self.formattedStartDate = dateFormatter.string(from: startDate)
        
        if let endDate {
            dateFormatter.dateFormat = calendar.isDateInToday(endDate) ? "HH:mm" : "E HH:mm"
            self.formattedEndDate = dateFormatter.string(from: endDate)
        } else {
            self.formattedEndDate = ""
        }
    }
    
    public init(persistenceModel: ActivityPersistenceModel) {
        self.init(id: persistenceModel.id,
                  startDate: persistenceModel.startDate,
                  endDate: persistenceModel.endDate,
                  type: ActivityType(rawValue: persistenceModel.activityTypeValue ?? "") ?? .sleep)
    }
}

