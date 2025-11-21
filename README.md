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
  - Clean layout with date on left, count on right
  - Filter defaults to day view on each app launch
- **Clean UI**: Minimal, distraction-free interface without ads ✅

## Technical Stack

- **Platform**: iOS
- **Language**: Swift with SwiftUI
- **Min iOS Version**: 17.0
- **Architecture**: SwiftUI App lifecycle
- **Bundle ID**: com.puffwise.app

## Project Structure

```
Puffwise/
├── Puffwise.xcodeproj/     # Xcode project configuration
└── Puffwise/
    ├── PuffwiseApp.swift   # App entry point with @main
    ├── ContentView.swift    # Main UI view with NavigationStack
    ├── HistoryView.swift    # Historical puff tracking view
    ├── Puff.swift           # Data model for puff tracking
    ├── PuffGrouping.swift   # Data grouping utilities (day/week/month)
    ├── Assets.xcassets/     # App icons and colors
    └── Preview Content/     # SwiftUI preview assets
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

## Development Status

### Current Implementation

✅ **Basic Puff Counter UI** (PR #2)
- Interactive puff logging with button tap
- Real-time count display
- SwiftUI @State management for reactive updates
- Clean, minimal interface with proper spacing

✅ **Data Persistence** (PR #3)
- @AppStorage property wrapper for persistent storage
- Puff counts survive app restarts
- Automatic synchronization with UserDefaults
- Seamless upgrade from @State with minimal code changes

✅ **Date-Based Puff Tracking** (PR #4)
- Puff data model with UUID and timestamp
- JSON encoding/decoding for storing array of Puffs
- Calendar-based date filtering for "Today's Puffs"
- Foundation for historical tracking and analytics
- Proper data structure for future features

✅ **Navigation Structure for History View** (PR #5)
- NavigationStack implementation for modern SwiftUI navigation
- NavigationLink in toolbar for accessing history
- HistoryView placeholder with proper navigation hierarchy
- Foundation for displaying historical puff data
- Educational comments explaining SwiftUI navigation patterns

✅ **Data Grouping Logic** (PR #6)
- PuffGrouping utilities for organizing puffs by time periods
- Support for grouping by day, week, and month
- PuffGroup struct with computed properties (count, isToday)
- Array extensions for fluent API: `puffs.groupedByDay()`
- Efficient O(n) grouping algorithm using Dictionary
- DateFormatter extensions for displaying group labels
- Comprehensive educational comments on Swift features:
  - Extension methods and protocol constraints
  - Dictionary-based grouping algorithms
  - Calendar component manipulation
  - Date normalization techniques
  - Static property optimization patterns

✅ **Historical List View** (PR #7)
- HistoryView implementation with daily puff count display
- SwiftUI List displaying grouped puff data
- @Binding property wrapper for data flow from ContentView
- Each row shows formatted date and total count
- Simple, reviewable implementation ready for enhancement
- Educational comments on:
  - @Binding for two-way data connections
  - List and ForEach for displaying collections
  - HStack layout and Spacer usage
  - Preview wrapper pattern for stateful previews

✅ **History Filtering** (PR #8)
- Dynamic filtering by day, week, or month using existing grouping logic
- Segmented control in toolbar for filter selection
- @State property wrapper for managing selected period
- Dynamic date formatting based on selected grouping period
- Utilizes PuffGrouping.swift infrastructure from PR #6
- Educational comments on:
  - SwiftUI Picker with segmented style
  - Toolbar modifiers with .principal placement
  - Dynamic formatter selection with helper methods
  - State management for view-local data

### Upcoming Features

- Data visualization and insights with charts
- MVVM architecture as complexity grows
