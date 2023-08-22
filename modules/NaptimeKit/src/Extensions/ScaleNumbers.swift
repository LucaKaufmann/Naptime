//
//  ScaleNumbers.swift
//  Naptime
//
//  Created by Luca Kaufmann on 30.1.2023.
//

import Foundation

public func scaleNumber(_ x: Double, fromMin: Double, fromMax: Double, toMin: Double, toMax: Double) -> Double {
    var num = clamp(x, min: fromMin, max: fromMax)
    return ((num - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin)
}

public func clamp(_ x: Double, min: Double, max: Double) -> Double {
    if x > max {
        return max
    } else if x < min {
        return min
    } else {
        return x
    }
}

public extension Double {
    func round(nearest: Double) -> Double {
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }

    func floor(nearest: Double) -> Double {
        let intDiv = Double(Int(self / nearest))
        return intDiv * nearest
    }
}
