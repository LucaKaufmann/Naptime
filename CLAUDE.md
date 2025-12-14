# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Naptime is a modular SwiftUI iOS app for tracking sleep and naps. It uses a micro-feature architecture pattern with Tuist for project generation. Features are written using The Composable Architecture (TCA), CoreData for persistence, and CloudKit for cross-device sync.

## Build Commands

```bash
# Install Tuist first: https://docs.tuist.io/tutorial/get-started/

# Fetch dependencies
tuist fetch

# Generate full Xcode project
tuist generate

# Generate specific feature only (for focused development)
tuist generate NaptimeStatistics

# Edit Tuist configuration
tuist edit

# Create new feature from template
tuist scaffold feature --name FeatureName
```

Code signing may need manual configuration or Xcode Managed signing to run the app.

## Architecture

### Module Structure

- **NaptimeApp** - Main app entry point, root feature, widget extension
- **NaptimeKit** - Core domain logic, CoreData persistence, CloudKit, Activity models/services
- **Activity** - Activity tracking feature with timer and list views
- **NaptimeSettings** - Settings feature (Live Activity prefs, CloudKit sharing)
- **NaptimeStatistics** - Statistics and analytics feature
- **DesignSystem** - Shared UI components, colors, button styles

### Micro-Feature Pattern

Each feature module follows this structure:
- `src/` - Implementation files
- `interface/` - Public interface
- `app/` - Feature app for isolated testing/preview
- `resources/` - Assets (colors, images)

### TCA Pattern

Features use The Composable Architecture with this structure:

```swift
public struct SomeFeature: Reducer {
    @Dependency(\.someService) private var someService

    public struct State: Equatable { ... }
    public enum Action: Equatable { ... }
    public var body: some ReducerOf<Self> { ... }
}
```

Key conventions:
- `*Feature.swift` - Contains Reducer definition
- `*View.swift` - SwiftUI views
- `*Service.swift` - Business logic services
- Use `@Dependency` for service injection
- Effects use `.run` and `.task` for async operations

### Tuist Configuration

Key files in `/Tuist/ProjectDescriptionHelpers/`:
- `Project+MicroFeature.swift` - Feature enum and dependency helpers
- `Project+Templates.swift` - Target templates (app, extension, framework)

To add a new feature:
1. Run `tuist scaffold feature --name FeatureName`
2. Run `tuist edit`
3. Add to `Feature` enum in `Project+Microfeature.swift`
4. Add dependencies in the feature's `Project.swift`
5. Close Xcode, press CTRL+C to save
6. Run `tuist generate`

## Key Technical Details

- **Deployment Target:** iOS 17.0+
- **Bundle ID:** `com.hotky.Naptime`
- **Product Type:** Static frameworks (TCA compatibility)
- **Data Model:** `/modules/NaptimeKit/src/NapTimeData/Naptime.xcdatamodeld`
- **Entitlements:** CloudKit, iCloud containers, app groups, push notifications

## Dependencies

Managed via Tuist/SPM:
- ComposableArchitecture (TCA) v1.0.0+
- AsyncAlgorithms v0.1.0+
- ScalingHeaderScrollView
- FoggyColors
