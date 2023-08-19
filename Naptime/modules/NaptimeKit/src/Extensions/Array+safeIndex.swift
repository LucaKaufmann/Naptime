//
//  Array+safeIndex.swift
//  Naptime
//
//  Created by Luca Kaufmann on 28.1.2023.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
