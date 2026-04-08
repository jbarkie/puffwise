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
  - **Undo/Trash**: Safety net for accidental deletions ✅
    - Deleted puffs move to trash instead of permanent removal
    - 24-hour recovery window to restore deleted puffs
    - Automatic purge of expired items
    - Trash accessible from History view with badge count
    - Swipe to restore or permanently delete individual items
- **Goal Setting**: Track progress toward daily reduction targets ✅
  - Set custom daily puff goal (1-100 puffs)
  - Persistent storage using @AppStorage
  - Settings accessible via toolbar gear icon
  - Progress display showing "X of Y puffs"
- **Data Export**: Export puff history for backup and analysis ✅
  - CSV format compatible with spreadsheet apps
  - Includes metadata (export date, total puffs, goal, date range)
  - RFC 4180 compliant CSV formatting
  - System share sheet integration for saving/sharing
- **Statistics Summary**: Track trends over time ✅
  - 7-day and 30-day puff averages
  - Displayed on main screen below goal progress
  - Automatically updates when puffs are added/edited/deleted
- **Streak Tracking**: Motivational streaks for consecutive days meeting goals ✅
  - Current streak display with flame icon
  - Best streak tracking (all-time personal best)
  - Automatic recalculation when puffs change or goals adjust
  - Smart handling of incomplete days and zero-puff days
- **Daily Reminders**: Optional notification to log puffs and check progress ✅
  - Configurable reminder time via settings
  - Persists across app restarts
- **Home Screen Widget**: Small widget showing today's count and goal ✅
  - Circular progress ring (green = on track, orange = over goal)
  - Updates immediately when a puff is logged in the app
  - Requires iOS 17.0+ and App Group entitlement
- **Reduction Goal Mode**: Automatic compounding weekly goal reduction ✅
  - Compounds the daily goal down by a configurable percentage each week
  - Dynamic daily allowance adjusts based on puffs already logged this week
  - Configurable weekly reduction rate (1–20%) and minimum floor
  - Trajectory chart on the home screen showing weeks until the floor is reached
  - Weekly target synced to the home screen widget
  - Pause detection: if last week's puff count exceeded the weekly target, the reduction holds for one more week before advancing
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
│   ├── TrashView.swift         # Trash/undo view for deleted puffs
│   ├── GoalSettingsView.swift  # Goal settings UI with @AppStorage
│   ├── Puff.swift              # Data model for puff tracking
│   ├── DeletedPuff.swift       # Data model for trashed puffs
│   ├── PuffGrouping.swift      # Data grouping utilities (day/week/month)
│   ├── StatisticsCalculator.swift  # Statistics calculation (7-day/30-day averages)
│   ├── StreakCalculator.swift  # Streak calculation logic
│   ├── ReductionPlan.swift     # Compounding weekly reduction model and dynamic daily goal
│   ├── CSVExporter.swift       # CSV export for data backup
│   ├── NotificationManager.swift   # Daily reminder notification scheduling
│   ├── SharedDefaults.swift    # UserDefaults App Group extension for widget data sharing
│   ├── Assets.xcassets/        # App icons and colors
│   └── Preview Content/        # SwiftUI preview assets
├── PuffwiseWidget/
│   └── PuffwiseWidget.swift    # Home screen widget (count + goal progress ring)
└── PuffwiseTests/
    └── PuffwiseTests.swift  # Comprehensive test suite (151 tests)
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

Puffwise includes a test suite built with Swift Testing framework to ensure code quality and correctness, with comprehensive coverage across the app's core functionality. Swift Testing framework (introduced in Swift 5.9) provides better error messages, native async/await support, and more Swift-native syntax than traditional XCTest.

```bash
# Run all tests
cd Puffwise
xcodebuild test -project Puffwise.xcodeproj -scheme Puffwise -destination 'platform=iOS Simulator,name=iPhone 16'

# Or run tests in Xcode
# Press Cmd+U or Product → Test
```
