//
//  NotificationCenter+persistence.swift
//  Naptime
//
//  Created by Luca Kaufmann on 6.4.2023.
//

import Foundation
import Combine

extension NotificationCenter {
    var storeDidChangePublisher: Publishers.ReceiveOn<NotificationCenter.Publisher, DispatchQueue> {
        return publisher(for: .cdcksStoreDidChange).receive(on: DispatchQueue.main)
    }
}
