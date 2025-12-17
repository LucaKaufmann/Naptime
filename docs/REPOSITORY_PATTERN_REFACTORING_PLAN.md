# Repository Pattern Refactoring Plan

## Executive Summary

This document outlines a comprehensive plan to refactor Naptime's persistence layer to use the Repository pattern. The goal is to decouple the app from Core Data, enabling future migration to alternative persistence frameworks (SwiftData, GRDB, or others) while improving testability and maintainability.

---

## Current Architecture Analysis

### Current Structure

```
┌─────────────────────┐
│   TCA Features      │
│  (ActivityFeature,  │
│   SettingsFeature)  │
└─────────┬───────────┘
          │ @Dependency
          ▼
┌─────────────────────┐
│  ActivityService    │
│  (NaptimeKit)       │
└─────────┬───────────┘
          │ direct dependency
          ▼
┌─────────────────────┐
│PersistenceController│
│   (Core Data)       │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ ActivityPersistence │
│ Model (NSManaged-   │
│ Object)             │
└─────────────────────┘
```

### Key Files Analyzed

| File | Purpose | Coupling Level |
|------|---------|----------------|
| `Persistence.swift` | Core Data stack setup, CloudKit sync, history tracking | High |
| `ActivityService.swift` | Business logic for activities (CRUD operations) | Medium |
| `ActivityPersistenceModel+CoreDataProperties.swift` | NSManagedObject subclass | High |
| `ActivityModel.swift` | Domain model (pure Swift struct) | Low |
| `ActivityDependencies.swift` | TCA dependency injection | Low |

### Current Problems

1. **Tight Coupling**: `ActivityService` directly depends on `PersistenceController` and Core Data types
2. **NSPredicate Usage**: Fetch operations use `NSPredicate` strings, tightly coupled to Core Data
3. **No Protocol Abstraction**: `ActivityService` is a concrete struct, not a protocol
4. **CloudKit Mixed In**: Sharing logic is intertwined with persistence
5. **Hard to Test**: Tests require `PersistenceController.preview` (actual Core Data stack)
6. **Model Conversion**: `ActivityModel(persistenceModel:)` directly references Core Data class

---

## Proposed Architecture

### Target Structure

```
┌─────────────────────────────────────────────────────────────┐
│                      TCA Features                           │
│         (ActivityFeature, SettingsFeature, etc.)            │
└─────────────────────────┬───────────────────────────────────┘
                          │ @Dependency(\.activityRepository)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              ActivityRepositoryClient (Protocol)             │
│   - fetchActivities(after: Date?) async -> [Activity]       │
│   - addActivity(Activity) async throws                      │
│   - updateActivity(Activity) async throws                   │
│   - deleteActivity(id: UUID) async throws                   │
│   - observeActivities() -> AsyncStream<[Activity]>          │
└─────────────────────────┬───────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ CoreData      │ │ GRDB          │ │ InMemory      │
│ Repository    │ │ Repository    │ │ Repository    │
│ (Production)  │ │ (Future)      │ │ (Testing)     │
└───────┬───────┘ └───────┬───────┘ └───────────────┘
        │                 │
        ▼                 ▼
┌───────────────┐ ┌───────────────┐
│ Core Data     │ │ SQLite        │
│ Stack         │ │ (GRDB)        │
└───────────────┘ └───────────────┘
```

---

## Domain Models

### Current Domain Model (Keep As-Is)

The existing `ActivityModel` is already a pure Swift struct, which is excellent:

```swift
// modules/NaptimeKit/src/NapTimeData/ActivityModel.swift
public struct ActivityModel: Equatable, Identifiable {
    public let id: UUID
    public var startDate: Date
    public var endDate: Date?
    public var type: ActivityType
    // ...
}
```

### Proposed: Remove Core Data Dependency from Domain

Remove the initializer that takes `ActivityPersistenceModel`:

```swift
// REMOVE: public init(persistenceModel: ActivityPersistenceModel)
// KEEP: public init(id: UUID, startDate: Date, endDate: Date?, type: ActivityType)
```

Mapping should happen **inside** the repository implementation, not in domain models.

---

## Repository Protocol Design

### Primary Repository Protocol

```swift
// modules/NaptimeKit/src/Repository/ActivityRepositoryProtocol.swift

import Foundation

public struct ActivityQuery {
    public var afterDate: Date?
    public var beforeDate: Date?
    public var types: [ActivityType]?
    public var limit: Int?
    public var sortOrder: SortOrder

    public enum SortOrder {
        case newestFirst
        case oldestFirst
    }

    public init(
        afterDate: Date? = nil,
        beforeDate: Date? = nil,
        types: [ActivityType]? = nil,
        limit: Int? = nil,
        sortOrder: SortOrder = .newestFirst
    ) {
        self.afterDate = afterDate
        self.beforeDate = beforeDate
        self.types = types
        self.limit = limit
        self.sortOrder = sortOrder
    }
}

public protocol ActivityRepositoryProtocol: Sendable {
    /// Fetch activities matching the query
    func fetch(query: ActivityQuery) async throws -> [ActivityModel]

    /// Add a new activity
    func add(_ activity: ActivityModel) async throws

    /// Update an existing activity
    func update(_ activity: ActivityModel) async throws

    /// Delete an activity by ID
    func delete(id: UUID) async throws

    /// Observe all activities (for real-time updates)
    func observe(query: ActivityQuery) -> AsyncStream<[ActivityModel]>
}
```

### TCA Dependency Client

```swift
// modules/NaptimeKit/src/Repository/ActivityRepositoryClient.swift

import ComposableArchitecture

public struct ActivityRepositoryClient: Sendable {
    public var fetch: @Sendable (ActivityQuery) async throws -> [ActivityModel]
    public var add: @Sendable (ActivityModel) async throws -> Void
    public var update: @Sendable (ActivityModel) async throws -> Void
    public var delete: @Sendable (UUID) async throws -> Void
    public var observe: @Sendable (ActivityQuery) -> AsyncStream<[ActivityModel]>

    public init(
        fetch: @escaping @Sendable (ActivityQuery) async throws -> [ActivityModel],
        add: @escaping @Sendable (ActivityModel) async throws -> Void,
        update: @escaping @Sendable (ActivityModel) async throws -> Void,
        delete: @escaping @Sendable (UUID) async throws -> Void,
        observe: @escaping @Sendable (ActivityQuery) -> AsyncStream<[ActivityModel]>
    ) {
        self.fetch = fetch
        self.add = add
        self.update = update
        self.delete = delete
        self.observe = observe
    }
}

// MARK: - Dependency Registration

extension ActivityRepositoryClient: DependencyKey {
    public static var liveValue: ActivityRepositoryClient {
        let repository = CoreDataActivityRepository(
            persistenceController: PersistenceController.shared
        )
        return ActivityRepositoryClient(repository: repository)
    }

    public static var testValue: ActivityRepositoryClient {
        let repository = InMemoryActivityRepository()
        return ActivityRepositoryClient(repository: repository)
    }

    public static var previewValue: ActivityRepositoryClient {
        let repository = InMemoryActivityRepository(
            activities: ActivityModel.previewData
        )
        return ActivityRepositoryClient(repository: repository)
    }
}

extension ActivityRepositoryClient {
    /// Convenience initializer from protocol
    public init(repository: ActivityRepositoryProtocol) {
        self.init(
            fetch: repository.fetch,
            add: repository.add,
            update: repository.update,
            delete: repository.delete,
            observe: repository.observe
        )
    }
}

extension DependencyValues {
    public var activityRepository: ActivityRepositoryClient {
        get { self[ActivityRepositoryClient.self] }
        set { self[ActivityRepositoryClient.self] = newValue }
    }
}
```

---

## Repository Implementations

### Core Data Implementation

```swift
// modules/NaptimeKit/src/Repository/CoreDataActivityRepository.swift

import Foundation
import CoreData

public final class CoreDataActivityRepository: ActivityRepositoryProtocol, @unchecked Sendable {
    private let persistenceController: PersistenceController

    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    public func fetch(query: ActivityQuery) async throws -> [ActivityModel] {
        let predicate = buildPredicate(from: query)
        let sortDescriptors = buildSortDescriptors(from: query)

        let persistenceModels = try await persistenceController.fetch(
            model: ActivityPersistenceModel.self,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: query.limit ?? 0
        )

        return persistenceModels.map { mapToModel($0) }
    }

    public func add(_ activity: ActivityModel) async throws {
        let context = persistenceController.backgroundContext
        let persistenceModel = ActivityPersistenceModel(context: context)
        mapToPersistence(activity, target: persistenceModel)
        try await persistenceController.saveBackgroundContext()
    }

    public func update(_ activity: ActivityModel) async throws {
        guard let existing = try await fetchPersistenceModel(id: activity.id) else {
            throw RepositoryError.notFound(id: activity.id)
        }
        mapToPersistence(activity, target: existing)
        try await persistenceController.saveBackgroundContext()
    }

    public func delete(id: UUID) async throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
            entityName: ActivityPersistenceModel.entity().name ?? ""
        )
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        try await persistenceController.delete(fetchRequest: fetchRequest)
    }

    public func observe(query: ActivityQuery) -> AsyncStream<[ActivityModel]> {
        AsyncStream { continuation in
            // Initial fetch
            Task {
                if let activities = try? await fetch(query: query) {
                    continuation.yield(activities)
                }
            }

            // Observe changes via NotificationCenter
            let observer = NotificationCenter.default.addObserver(
                forName: .cdcksStoreDidChange,
                object: nil,
                queue: nil
            ) { _ in
                Task {
                    if let activities = try? await self.fetch(query: query) {
                        continuation.yield(activities)
                    }
                }
            }

            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(observer)
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

public enum RepositoryError: Error {
    case notFound(id: UUID)
    case saveFailed(underlying: Error)
}
```

### In-Memory Implementation (Testing)

```swift
// modules/NaptimeKit/src/Repository/InMemoryActivityRepository.swift

import Foundation

public actor InMemoryActivityRepository: ActivityRepositoryProtocol {
    private var activities: [ActivityModel]
    private var continuations: [UUID: AsyncStream<[ActivityModel]>.Continuation] = [:]

    public init(activities: [ActivityModel] = []) {
        self.activities = activities
    }

    public func fetch(query: ActivityQuery) async throws -> [ActivityModel] {
        var result = activities

        if let afterDate = query.afterDate {
            result = result.filter { $0.startDate > afterDate }
        }
        if let beforeDate = query.beforeDate {
            result = result.filter { $0.startDate < beforeDate }
        }
        if let types = query.types {
            result = result.filter { types.contains($0.type) }
        }

        result.sort { lhs, rhs in
            query.sortOrder == .newestFirst
                ? lhs.startDate > rhs.startDate
                : lhs.startDate < rhs.startDate
        }

        if let limit = query.limit, limit > 0 {
            result = Array(result.prefix(limit))
        }

        return result
    }

    public func add(_ activity: ActivityModel) async throws {
        activities.append(activity)
        notifyObservers()
    }

    public func update(_ activity: ActivityModel) async throws {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else {
            throw RepositoryError.notFound(id: activity.id)
        }
        activities[index] = activity
        notifyObservers()
    }

    public func delete(id: UUID) async throws {
        activities.removeAll { $0.id == id }
        notifyObservers()
    }

    public func observe(query: ActivityQuery) -> AsyncStream<[ActivityModel]> {
        let id = UUID()
        return AsyncStream { continuation in
            Task {
                // Store continuation for updates
                self.continuations[id] = continuation

                // Yield initial value
                if let activities = try? await self.fetch(query: query) {
                    continuation.yield(activities)
                }
            }

            continuation.onTermination = { _ in
                Task { await self.removeContinuation(id: id) }
            }
        }
    }

    private func notifyObservers() {
        for continuation in continuations.values {
            continuation.yield(activities)
        }
    }

    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }
}
```

---

## CloudKit Sharing Strategy

### Separate CloudKit Concerns

CloudKit sharing should be handled by a separate service, not mixed with the repository:

```swift
// modules/NaptimeKit/src/CloudKit/CloudKitSharingService.swift

public protocol CloudKitSharingServiceProtocol {
    func share(activityIds: [UUID]) async throws -> CKShare
    func getActiveShares() async throws -> [CKShare]
    func acceptShare(_ metadata: CKShare.Metadata) async throws
}

public struct CloudKitSharingClient: DependencyKey {
    public var share: @Sendable ([UUID]) async throws -> CKShare
    public var getActiveShares: @Sendable () async throws -> [CKShare]
    public var acceptShare: @Sendable (CKShare.Metadata) async throws -> Void

    public static var liveValue: CloudKitSharingClient { /* ... */ }
    public static var testValue: CloudKitSharingClient { /* noop */ }
}
```

---

## Migration Steps

### Phase 1: Create Repository Layer (Non-Breaking)

1. Create `ActivityRepositoryProtocol` and `ActivityRepositoryClient`
2. Implement `CoreDataActivityRepository` wrapping existing `PersistenceController`
3. Implement `InMemoryActivityRepository` for testing
4. Register as TCA dependency alongside existing `ActivityService`

**Files to Create:**
- `modules/NaptimeKit/src/Repository/ActivityRepositoryProtocol.swift`
- `modules/NaptimeKit/src/Repository/ActivityRepositoryClient.swift`
- `modules/NaptimeKit/src/Repository/CoreDataActivityRepository.swift`
- `modules/NaptimeKit/src/Repository/InMemoryActivityRepository.swift`

### Phase 2: Migrate Features

1. Update `ActivityFeature` to use `@Dependency(\.activityRepository)` instead of `activityService`
2. Update `SettingsFeature`, `StatisticsFeature`, etc.
3. Keep `ActivityService` temporarily for backward compatibility

**Files to Modify:**
- `modules/Activity/src/ActivityFeature.swift`
- `modules/Activity/src/ActivityDependencies/ActivityDependencies.swift`
- `modules/NaptimeStatistics/src/StatisticsDependencies.swift`
- `modules/NaptimeSettings/src/ActivityDependencies.swift`

### Phase 3: Clean Up

1. Remove `ActivityModel(persistenceModel:)` initializer
2. Move mapping logic entirely into `CoreDataActivityRepository`
3. Deprecate and remove `ActivityService`
4. Extract CloudKit sharing to separate service

### Phase 4: Alternative Backend (Future)

1. Add GRDB or SwiftData implementation
2. Create feature flag or build configuration to switch backends
3. Test with new backend in development
4. Migrate production users

---

## Alternative Persistence Framework Recommendation

Based on research, here are the recommended alternatives:

### Option 1: GRDB.swift (Recommended)

**Pros:**
- Direct SQLite access with excellent performance
- Better control over queries and migrations
- [Point-Free's SharingGRDB](https://github.com/pointfreeco/swift-composable-architecture/discussions/1145) integrates well with TCA
- Active community and maintenance
- Explicit schema control

**Cons:**
- Need to manage CloudKit sync separately
- Manual schema migrations

### Option 2: SwiftData

**Pros:**
- Apple's modern replacement for Core Data
- Built-in CloudKit support
- SwiftUI integration with @Query

**Cons:**
- [Still maturing](https://mjtsai.com/blog/2024/10/16/returning-to-core-data/), some bugs reported in iOS 17-18
- [Missing advanced features](https://medium.com/@sachindrafernando3/swiftdata-in-production-migrating-from-coredata-pros-cons-pitfalls-1b3fddab0825) like NSFetchedResultsController
- Heavyweight migrations not yet supported

### Option 3: Keep Core Data with Better Abstraction

**Pros:**
- No migration needed
- Proven stability
- Full CloudKit integration

**Cons:**
- Verbose API
- NSManagedObject quirks

### Recommendation

Given the CloudKit sharing requirement in Naptime, I recommend:

1. **Short-term**: Implement repository pattern with Core Data
2. **Medium-term**: Evaluate GRDB + custom CloudKit sync
3. **Long-term**: Consider SwiftData when iOS 18+ adoption is high and stability improves

---

## Testing Strategy

### Unit Tests for Repository

```swift
import XCTest
@testable import NaptimeKit

final class InMemoryActivityRepositoryTests: XCTestCase {
    var repository: InMemoryActivityRepository!

    override func setUp() {
        repository = InMemoryActivityRepository()
    }

    func testAddAndFetch() async throws {
        let activity = ActivityModel(
            id: UUID(),
            startDate: Date(),
            endDate: nil,
            type: .sleep
        )

        try await repository.add(activity)
        let fetched = try await repository.fetch(query: .init())

        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, activity.id)
    }

    func testQueryFiltering() async throws {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!

        try await repository.add(ActivityModel(id: UUID(), startDate: now, endDate: nil, type: .sleep))
        try await repository.add(ActivityModel(id: UUID(), startDate: yesterday, endDate: nil, type: .sleep))

        let query = ActivityQuery(afterDate: Calendar.current.startOfDay(for: now))
        let result = try await repository.fetch(query: query)

        XCTAssertEqual(result.count, 1)
    }
}
```

### TCA Feature Tests

```swift
import ComposableArchitecture
import XCTest
@testable import Activity

final class ActivityFeatureTests: XCTestCase {
    func testStartActivity() async {
        let store = TestStore(
            initialState: ActivityFeature.State(/* ... */),
            reducer: { ActivityFeature() }
        ) {
            $0.activityRepository = .init(
                fetch: { _ in [] },
                add: { _ in },
                update: { _ in },
                delete: { _ in },
                observe: { _ in AsyncStream { _ in } }
            )
        }

        await store.send(.startActivity(.sleep)) {
            $0.activities.insert(/* ... */)
        }
    }
}
```

---

## File Structure After Refactoring

```
modules/NaptimeKit/src/
├── Repository/
│   ├── ActivityRepositoryProtocol.swift
│   ├── ActivityRepositoryClient.swift
│   ├── CoreDataActivityRepository.swift
│   ├── InMemoryActivityRepository.swift
│   └── RepositoryError.swift
├── CloudKit/
│   ├── CloudKitSharingService.swift
│   └── CloudKitSharingClient.swift
├── NapTimeData/
│   ├── Persistence.swift (Core Data stack only)
│   ├── ActivityPersistenceModel+CoreDataClass.swift
│   └── ActivityPersistenceModel+CoreDataProperties.swift
└── Models/
    ├── ActivityModel.swift
    └── ActivityType.swift
```

---

## Implementation Checklist

- [ ] Create `Repository/` directory in NaptimeKit
- [ ] Define `ActivityRepositoryProtocol`
- [ ] Create `ActivityRepositoryClient` with TCA DependencyKey
- [ ] Implement `CoreDataActivityRepository`
- [ ] Implement `InMemoryActivityRepository`
- [ ] Add unit tests for repositories
- [ ] Update `ActivityFeature` to use repository
- [ ] Update other features (Settings, Statistics)
- [ ] Remove `ActivityModel(persistenceModel:)` initializer
- [ ] Deprecate `ActivityService`
- [ ] Extract CloudKit sharing to separate service
- [ ] Update all TCA feature tests
- [ ] Integration testing with Core Data backend

---

## Sources

- [Repository Design Pattern in Swift - SwiftLee](https://www.avanderlee.com/swift/repository-design-pattern/)
- [iOS Repository Pattern - Medium](https://medium.com/tiendeo-tech/ios-repository-pattern-in-swift-85a8c62bf436)
- [Local-First Architectures with SwiftData](https://medium.com/@gauravharkhani01/designing-efficient-local-first-architectures-with-swiftdata-cc74048526f2)
- [SwiftData in Production: Migrating from CoreData](https://medium.com/@sachindrafernando3/swiftdata-in-production-migrating-from-coredata-pros-cons-pitfalls-1b3fddab0825)
- [SwiftData vs Core Data 2025](https://www.hashstudioz.com/blog/swiftdata-vs-core-data-which-should-you-choose-in-2025/)
- [Returning to Core Data - Michael Tsai](https://mjtsai.com/blog/2024/10/16/returning-to-core-data/)
- [GRDB.swift - Why Adopt GRDB](https://github.com/groue/GRDB.swift/blob/master/Documentation/WhyAdoptGRDB.md)
- [GRDB.swift GitHub](https://github.com/groue/GRDB.swift)
- [Shared State in TCA - Point-Free](https://www.pointfree.co/blog/posts/135-shared-state-in-the-composable-architecture)
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
