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
