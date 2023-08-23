//
//  ActivityTile.swift
//  Naptime
//
//  Created by Luca Kaufmann on 8.2.2023.
//

import Foundation

public enum ActivityTileType {
    case sleepToday, napsToday, usualBedtime
}

public struct ActivityTile: Identifiable, Equatable {
    public let id: UUID
    let title: String
    let subtitle: String
    let type: ActivityTileType
}
