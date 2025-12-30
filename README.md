# Puffwise

Puffwise is a habit-tracking app that helps users cut down on smoking or vaping through puff counting, insights, and progress tracking.

## Overview

Puffwise is designed to provide a better user experience than existing habit-tracking alternatives in this space. Rather than focusing on monetization through ads, Puffwise prioritizes a clean, ad-free interface with thoughtful features that genuinely help users track and reduce their nicotine consumption.

## MVP Features

- **Puff Counter**: Simple, quick logging of individual puffs ✅
  - Interactive button to log each puff
  - Real-time count display with timestamp tracking
  - Clean, accessible UI with large tap targets
- **Daily Summary**: View total puff count for the current day ✅
  - Each puff logged with timestamp
  - Persistent storage using UserDefaults with JSON encoding
  - Smart date filtering to show only today's puffs
  - Data survives app restarts
- **Basic History**: See puff counts for previous days ✅
  - List view displaying puff counts grouped by day, week, or month
  - Segmented control for switching between grouping periods
  - Formatted date labels for each period (e.g., "Jan 15, 2024" or "Week of Jan 15")
  - Section-based layout showing individual puffs within each time period
  - Filter defaults to day view on each app launch
  - **Edit/Delete Puffs**: Correct mistakes in puff tracking ✅
    - Tap any puff to edit its timestamp (date and time)
    - Swipe to delete individual puffs
    - Changes auto-save to persistent storage
    - Groups and charts update automatically
- **Goal Setting**: Track progress toward daily reduction targets ✅
  - Set custom daily puff goal (1-100 puffs)
  - Persistent storage using @AppStorage
  - Settings accessible via toolbar gear icon
  - Progress display showing "X of Y puffs"
- **Clean UI**: Minimal, distraction-free interface without ads ✅

## Technical Stack

- **Platform**: iOS
- **Language**: Swift with SwiftUI
- **Min iOS Version**: 17.0
- **Architecture**: SwiftUI App lifecycle
- **Bundle ID**: com.puffwise.app
- **Settings Management**: Form-based settings UI with @AppStorage persistence

## Project Structure

```
Puffwise/
├── Puffwise.xcodeproj/     # Xcode project configuration
├── Puffwise/
│   ├── PuffwiseApp.swift       # App entry point with @main
│   ├── ContentView.swift       # Main UI view with NavigationStack
│   ├── HistoryView.swift       # Historical puff tracking view
│   ├── EditPuffView.swift      # Edit puff timestamp UI with DatePicker
│   ├── GoalSettingsView.swift  # Goal settings UI with @AppStorage
│   ├── Puff.swift              # Data model for puff tracking
│   ├── PuffGrouping.swift      # Data grouping utilities (day/week/month)
│   ├── Assets.xcassets/        # App icons and colors
│   └── Preview Content/        # SwiftUI preview assets
└── PuffwiseTests/
    └── PuffwiseTests.swift  # Comprehensive test suite (37 tests)
```

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- macOS with iOS 17.0 SDK

### Building the Project

```bash
# Clone the repository
git clone https://github.com/jbarkie/puffwise.git
cd puffwise

# Open in Xcode
open Puffwise/Puffwise.xcodeproj

# Or build from command line
cd Puffwise
xcodebuild -project Puffwise.xcodeproj -scheme Puffwise -destination 'generic/platform=iOS Simulator' build
```

### Running Tests

Puffwise includes a test suite built with Swift Testing framework to ensure code quality and correctness.

```bash
# Run all tests
cd Puffwise
xcodebuild test -project Puffwise.xcodeproj -scheme Puffwise -destination 'platform=iOS Simulator,name=iPhone 16'

# Or run tests in Xcode
# Press Cmd+U or Product → Test
```

**Current Test Coverage:**

The test suite uses Swift Testing framework (Swift 5.9+) with comprehensive coverage across the app's core functionality:

- **PuffGrouping Tests** (8 tests): Date grouping and sorting logic

  - Daily, weekly, and monthly grouping algorithms
  - Empty array and single puff edge cases
  - Year boundary transitions
  - Multiple puffs with same timestamp handling
  - Newest-first sorting verification

- **Puff Model Tests** (6 tests): Core data model validation

  - Default and custom initialization
  - UUID uniqueness and stability
  - Codable conformance (JSON encoding/decoding)
  - Array encoding/decoding for persistence

- **PuffGroup Model Tests** (4 tests): Grouping data structure

  - Count property accuracy
  - isToday property behavior
  - Identifiable conformance and ID stability

- **DateFormatter Tests** (4 tests): Formatter extensions
  - Day, week, and month formatting
  - Static formatter reusability and performance

- **Goal Settings Tests** (4 tests): Goal persistence and validation
  - Default value initialization
  - UserDefaults persistence
  - Range validation (1-100 bounds)
  - Goal update functionality

- **Puff Edit/Delete Tests** (11 tests): Edit and delete functionality
  - Delete puff removes from array while preserving others
  - Delete all puffs in a group (empty group handling)
  - Delete today's puff updates today's count correctly
  - Edit puff preserves ID while updating timestamp
  - Edit puff to different day updates grouping correctly
  - Edit today's puff to yesterday affects counts
  - Multiple sequential edits to same puff
  - Edit across month boundaries
  - Edit preserves array integrity (no duplication/deletion)
  - Edit to same timestamp is idempotent

**Total: 37 tests, all passing**

The tests use Swift Testing framework (introduced in Swift 5.9), which provides better error messages, native async/await support, and more Swift-native syntax than traditional XCTest.
