# Puffwise

Puffwise is a habit-tracking app that helps users cut down on smoking or vaping through puff counting, insights, and progress tracking.

## Overview

Puffwise is designed to provide a better user experience than existing habit-tracking alternatives in this space. Rather than focusing on monetization through ads, Puffwise prioritizes a clean, ad-free interface with thoughtful features that genuinely help users track and reduce their nicotine consumption.

## MVP Features

- **Puff Counter**: Simple, quick logging of individual puffs
- **Daily Summary**: View total puff count for the current day
- **Basic History**: See puff counts for previous days
- **Clean UI**: Minimal, distraction-free interface without ads

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

The Xcode project has been initialized with a basic SwiftUI app structure. Next steps include implementing data models, persistence layer, and the core puff counter UI.
