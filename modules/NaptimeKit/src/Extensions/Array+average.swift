//
//  Array+average.swift
//  Naptime
//
//  Created by Luca Kaufmann on 12.2.2023.
//

import Foundation

public extension Array where Element: BinaryInteger {

    /// The average value of all the items in the array
    var average: Double {
        if self.isEmpty {
            return 0.0
        } else {
            let sum = self.reduce(0, +)
            return Double(sum) / Double(self.count)
        }
    }

}

public extension Array where Element: BinaryFloatingPoint {

    /// The average value of all the items in the array
    var average: Double {
        if self.isEmpty {
            return 0.0
        } else {
            let sum = self.reduce(0, +)
            return Double(sum) / Double(self.count)
        }
    }
}

public extension Array where Element == Int {
    func median() -> Double? {
        guard count > 0  else { return nil }

        let sortedArray = self.sorted()
        if count % 2 != 0 {
            return Double(sortedArray[count/2])
        } else {
            return Double(sortedArray[count/2] + sortedArray[count/2 - 1]) / 2.0
        }
    }
}
