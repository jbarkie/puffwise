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
- **Basic History**: See puff counts for previous days (Planned)
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
    ├── ContentView.swift    # Main UI view
    ├── Puff.swift           # Data model for puff tracking
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

### Upcoming Features

- Historical view of puff counts by day
- Data visualization and insights
- MVVM architecture as complexity grows
