//
//  NapModel.swift
//  Naptime
//
//  Created by Luca Kaufmann on 4.12.2022.
//

import Foundation

enum ActivityType: String {
    case sleep = "sleep"
    case tummyTime = "Tummy time"
    
    var icon: String {
        switch self {
        case .sleep:
            return "bed.double.circle"
        case .tummyTime:
            return ""
        }
    }
}

struct ActivityModel: Equatable, Identifiable {
    let id: UUID
    
    var startDate: Date
    var endDate: Date?
    var type: ActivityType
    
    var isActive: Bool {
        return endDate == nil
    }
    
    var formattedStartDate: String {
        return formattedDate(startDate)
    }
    
    var formattedEndDate: String {
        guard let endDate else {
            return ""
        }
        return formattedDate(endDate)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = calendar.isDateInToday(date) ? "HH:mm" : "E HH:mm"
        return dateFormatter.string(from: date)
    }
    
    init(id: UUID, startDate: Date, endDate: Date?, type: ActivityType) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
    }
    
    init(persistenceModel: ActivityPersistenceModel) {
        self.init(id: persistenceModel.id,
                  startDate: persistenceModel.startDate,
                  endDate: persistenceModel.endDate,
                  type: ActivityType(rawValue: persistenceModel.activityTypeValue ?? "") ?? .sleep)
    }
}

