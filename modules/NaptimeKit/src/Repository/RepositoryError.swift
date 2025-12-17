//
//  RepositoryError.swift
//  NaptimeKit
//
//  Created by Claude on 2024.
//

import Foundation

/// Errors that can occur during repository operations
public enum RepositoryError: Error, Equatable {
    /// The requested entity was not found
    case notFound(id: UUID)

    /// Failed to save changes to the persistence layer
    case saveFailed(message: String)

    /// Failed to fetch data from the persistence layer
    case fetchFailed(message: String)

    /// Failed to delete the entity
    case deleteFailed(message: String)
}

extension RepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "Entity with id \(id) was not found"
        case .saveFailed(let message):
            return "Failed to save: \(message)"
        case .fetchFailed(let message):
            return "Failed to fetch: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete: \(message)"
        }
    }
}
