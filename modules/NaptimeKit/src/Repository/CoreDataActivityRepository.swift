//
//  CoreDataActivityRepository.swift
//  NaptimeKit
//
//  Created by Claude on 2024.
//

import CoreData
import Foundation
import OSLog

/// Core Data implementation of ActivityRepositoryProtocol
///
/// This repository wraps the existing PersistenceController and provides
/// a clean interface for activity persistence operations.
public final class CoreDataActivityRepository: ActivityRepositoryProtocol, @unchecked Sendable {
    private let persistenceController: PersistenceController

    /// Initialize with a persistence controller
    /// - Parameter persistenceController: The Core Data persistence controller
    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    // MARK: - ActivityRepositoryProtocol

    public func fetch(query: ActivityQuery) async throws -> [ActivityModel] {
        let predicate = buildPredicate(from: query)
        let sortDescriptors = buildSortDescriptors(from: query)
        let limit = query.limit ?? 0

        do {
            let persistenceModels = try await persistenceController.fetch(
                model: ActivityPersistenceModel.self,
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                limit: limit
            )

            let activities = persistenceModels.map { mapToModel($0) }

            os_log("Fetched %d activities",
                   log: OSLog.persistence,
                   type: .info,
                   activities.count)

            return activities
        } catch {
            os_log("Failed to fetch activities: %@",
                   log: OSLog.persistence,
                   type: .error,
                   error.localizedDescription)
            throw RepositoryError.fetchFailed(message: error.localizedDescription)
        }
    }

    public func add(_ activity: ActivityModel) async throws {
        let context = persistenceController.backgroundContext

        await context.perform {
            let persistenceModel = ActivityPersistenceModel(context: context)
            self.mapToPersistence(activity, target: persistenceModel)
        }

        // Handle CloudKit sharing for existing shares
        do {
            let shares = persistenceController.getSharedShareRecord()

            // Fetch the newly created persistence model to share it
            if !shares.isEmpty {
                if let persistenceModel = try await fetchPersistenceModel(id: activity.id) {
                    for share in shares {
                        _ = try? await persistenceController.shareObject(persistenceModel, to: share)
                    }
                }
            }

            try await persistenceController.saveBackgroundContext()

            os_log("Added activity: %@",
                   log: OSLog.persistence,
                   type: .info,
                   activity.id.uuidString)
        } catch {
            os_log("Failed to add activity: %@",
                   log: OSLog.persistence,
                   type: .error,
                   error.localizedDescription)
            throw RepositoryError.saveFailed(message: error.localizedDescription)
        }
    }

    public func update(_ activity: ActivityModel) async throws {
        guard let persistenceModel = try await fetchPersistenceModel(id: activity.id) else {
            throw RepositoryError.notFound(id: activity.id)
        }

        let context = persistenceController.backgroundContext

        await context.perform {
            self.mapToPersistence(activity, target: persistenceModel)
        }

        // Handle CloudKit sharing
        do {
            let shares = persistenceController.getSharedShareRecord()
            for share in shares {
                _ = try? await persistenceController.shareObject(persistenceModel, to: share)
            }

            try await persistenceController.saveBackgroundContext()

            os_log("Updated activity: %@",
                   log: OSLog.persistence,
                   type: .info,
                   activity.id.uuidString)
        } catch {
            os_log("Failed to update activity: %@",
                   log: OSLog.persistence,
                   type: .error,
                   error.localizedDescription)
            throw RepositoryError.saveFailed(message: error.localizedDescription)
        }
    }

    public func delete(id: UUID) async throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
            entityName: ActivityPersistenceModel.entity().name ?? "ActivityPersistenceModel"
        )
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            try await persistenceController.delete(fetchRequest: fetchRequest)
            try await persistenceController.saveBackgroundContext()

            os_log("Deleted activity: %@",
                   log: OSLog.persistence,
                   type: .info,
                   id.uuidString)
        } catch {
            os_log("Failed to delete activity: %@",
                   log: OSLog.persistence,
                   type: .error,
                   error.localizedDescription)
            throw RepositoryError.deleteFailed(message: error.localizedDescription)
        }
    }

    public func observe(query: ActivityQuery) -> AsyncStream<[ActivityModel]> {
        AsyncStream { continuation in
            // Initial fetch
            Task {
                if let activities = try? await self.fetch(query: query) {
                    continuation.yield(activities)
                }
            }

            // Observe Core Data changes via NotificationCenter
            let observer = NotificationCenter.default.addObserver(
                forName: .cdcksStoreDidChange,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                guard let self = self else { return }
                Task {
                    if let activities = try? await self.fetch(query: query) {
                        continuation.yield(activities)
                    }
                }
            }

            // Also observe local context saves
            let saveObserver = NotificationCenter.default.addObserver(
                forName: .NSManagedObjectContextDidSave,
                object: nil,
                queue: nil
            ) { [weak self] notification in
                guard let self = self else { return }
                // Only react to saves from our contexts
                guard notification.object as? NSManagedObjectContext != nil else { return }
                Task {
                    if let activities = try? await self.fetch(query: query) {
                        continuation.yield(activities)
                    }
                }
            }

            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(observer)
                NotificationCenter.default.removeObserver(saveObserver)
            }
        }
    }

    // MARK: - Private Helpers

    private func buildPredicate(from query: ActivityQuery) -> NSPredicate? {
        var predicates: [NSPredicate] = []

        if let afterDate = query.afterDate {
            predicates.append(NSPredicate(format: "startDate > %@", afterDate as CVarArg))
        }

        if let beforeDate = query.beforeDate {
            predicates.append(NSPredicate(format: "startDate < %@", beforeDate as CVarArg))
        }

        if let types = query.types, !types.isEmpty {
            let typeStrings = types.map { $0.rawValue }
            predicates.append(NSPredicate(format: "activityTypeValue IN %@", typeStrings))
        }

        guard !predicates.isEmpty else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    private func buildSortDescriptors(from query: ActivityQuery) -> [NSSortDescriptor] {
        let ascending = query.sortOrder == .oldestFirst
        return [NSSortDescriptor(key: "startDate", ascending: ascending)]
    }

    private func mapToModel(_ persistence: ActivityPersistenceModel) -> ActivityModel {
        ActivityModel(
            id: persistence.id,
            startDate: persistence.startDate,
            endDate: persistence.endDate,
            type: ActivityType(rawValue: persistence.activityTypeValue ?? "") ?? .sleep
        )
    }

    private func mapToPersistence(_ model: ActivityModel, target: ActivityPersistenceModel) {
        target.id = model.id
        target.startDate = model.startDate
        target.endDate = model.endDate
        target.activityTypeValue = model.type.rawValue
    }

    private func fetchPersistenceModel(id: UUID) async throws -> ActivityPersistenceModel? {
        try await persistenceController.fetch(
            model: ActivityPersistenceModel.self,
            predicate: NSPredicate(format: "id == %@", id as CVarArg)
        ).first
    }
}

// MARK: - Convenience Factory

public extension CoreDataActivityRepository {
    /// Create a repository using the shared persistence controller
    static var shared: CoreDataActivityRepository {
        CoreDataActivityRepository(persistenceController: PersistenceController.shared)
    }

    /// Create a repository for previews using in-memory storage
    static var preview: CoreDataActivityRepository {
        CoreDataActivityRepository(persistenceController: PersistenceController.preview)
    }
}
