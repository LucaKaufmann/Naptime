//
//  Date+Stuff.swift
//  Naptime
//
//  Created by Luca Kaufmann on 10.2.2023.
//

import Foundation

extension Date {
    
    func isCurrentDay() -> Bool {
        let calendar: Calendar = Calendar.current
        let comp = calendar.dateComponents([.year, .month, .day], from: self)
        let nowComp = calendar.dateComponents([.year, .month, .day], from: Date())
        return comp.year == nowComp.year && comp.month == nowComp.month && comp.day == nowComp.day
    }
    
    func startOf(_ component: Calendar.Component) -> Date { // Not tested yet
        var startOfComponent = self
        var timeInterval: TimeInterval = 0.0
        _ = Calendar.current.dateInterval(of: component, start: &startOfComponent, interval: &timeInterval, for: self)
        return startOfComponent
    }
    
}
