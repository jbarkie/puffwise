# Puffwise

Puffwise is a habit-tracking app that helps users cut down on smoking or vaping through puff counting, insights, and progress tracking.

## Overview

Puffwise is designed to provide a better user experience than existing habit-tracking alternatives in this space. Rather than focusing on monetization through ads, Puffwise prioritizes a clean, ad-free interface with thoughtful features that genuinely help users track and reduce their nicotine consumption.

## MVP Features

- **Puff Counter**: Simple, quick logging of individual puffs
- **Daily Summary**: View total puff count for the current day
- **Basic History**: See puff counts for previous days
- **Clean UI**: Minimal, distraction-free interface without ads

## Implementation

- **Platform**: iOS 17.0+
- **Language**: Swift with SwiftUI
- **Architecture**: SwiftUI App lifecycle

## Getting Started

### Prerequisites

- macOS with Xcode 15.4+
- iOS Simulator or physical iOS device

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/jbarkie/puffwise.git
   cd puffwise
   ```

2. Open the project in Xcode:
   ```bash
   open Puffwise/Puffwise.xcodeproj
   ```

3. Select a simulator or device, then press `Cmd+R` to build and run

### Building from Command Line

```bash
cd Puffwise
xcodebuild -project Puffwise.xcodeproj -scheme Puffwise -destination 'generic/platform=iOS Simulator' build
```

## Project Status

Currently in early development. The project structure is set up and ready for feature implementation.

**Completed:**
- ✅ Initial project setup with SwiftUI

**Next up:**
- Puff counter implementation
- Data model design
- Persistence layer
