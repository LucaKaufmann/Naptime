//
//  Array+mapInPlace.swift
//  Naptime
//
//  Created by Luca Kaufmann on 12.2.2023.
//

import Foundation

extension Array {
    mutating func mapInPlace(_ transform: (Element) -> Element) {
        self = map(transform)
    }
}
