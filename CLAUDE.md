# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Puffwise is an iOS habit-tracking app designed to help users reduce smoking/vaping through puff counting, insights, and progress tracking. The app prioritizes a clean, ad-free user experience.

**Platform**: iOS
**Language**: Swift with SwiftUI

## Sprint Workflow

All development follows a sprint-based Agile/Scrum workflow. See `docs/SPRINT_EXECUTION_WORKFLOW.md` for the full 7-phase process.

**Startup**: Run `/startup-check` at the start of every session to restore sprint context.

**Branch Policy**:
- Feature branches: `feature/YYYYMMDD_Sprint_N`
- All PRs target **main**
- Never commit directly to main

**Sprint Authority**:
- Once a sprint plan is approved in Phase 3, all tasks within that plan are pre-authorized
- Do not stop for per-task approval
- Only stop for criteria in `docs/SPRINT_STOPPING_CRITERIA.md`

**Key Documents**:
- `docs/ALL_SPRINTS_MASTER_PLAN.md` — Authoritative backlog and sprint history
- `docs/SPRINT_EXECUTION_WORKFLOW.md` — 7-phase execution process
- `docs/SPRINT_PLANNING.md` — Sprint structure and model assignment
- `docs/SPRINT_STOPPING_CRITERIA.md` — When to escalate
- `docs/MODEL_ASSIGNMENT_HEURISTICS.md` — Haiku / Sonnet / Opus routing
- `.claude/sprint_status.json` — Current sprint state

**Code Standards**:
- No `print()` in production code
- No contractions in commit messages or documentation
- Commit format: `type: description (#issue)`

## Development Workflow

This is a learning project for the developer's first iOS app. All development follows a structured workflow:

1. **Feature Branches**: All work happens in feature branches (never commit directly to main)
2. **Pull Requests**: Features must be merged to main via pull request
3. **Educational Focus**: Code should be well-commented and explain Swift/SwiftUI concepts as they are introduced
4. **Testing**: All tests must pass before committing changes
5. **Code Quality**: Run the build-validator agent before committing and before opening PRs

When implementing features:

- Create a feature branch: `git checkout -b feature/YYYYMMDD_Sprint_N`
- Make commits with clear, descriptive messages
- **Ensure all tests pass**: Run `xcodebuild test` and verify all tests pass before committing
- **Run build-validator agent**: Confirm zero build errors and all tests pass
- Fix any issues identified before proceeding
- **Verify with iOS Simulator**: Use the ios-simulator MCP to build, install, and visually verify changes in the simulator before opening PRs
- Push and create PR when ready: `gh pr create`
- Explain key iOS/Swift concepts in PR descriptions
- **Update documentation**: PRs should include updates to README.md and other relevant documentation when meaningful changes are made (new features, behavior changes, UI updates, etc.)

### Pull Request Template

Use this concise format for PR descriptions:

```markdown
## Summary

[1-3 sentences: What this PR does and why]

## What Changed

- **file.swift**: [Brief description of changes]
- **file2.swift**: [Brief description of changes]

## Swift/SwiftUI Concepts

[Only for PRs introducing new patterns. List 2-4 key concepts with one-line explanations]

## Test Plan

- [ ] All tests pass
- [ ] Verified in iOS Simulator via ios-simulator MCP
- [ ] [Any feature-specific manual checks]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**Guidelines:**

- Keep summaries brief—avoid restating the title
- Don't include code snippets unless they clarify something non-obvious
- Swift/SwiftUI Concepts section is optional for small changes
- Skip Implementation Details if What Changed already explains it

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.

## Current State

**Core Features:**

- Puff logging with daily goal tracking (1-100 puffs)
- Statistics display (7-day and 30-day averages)
- Streak tracking (consecutive days meeting goal, with flame icon)
- History view with bar charts and day/week/month filtering
- Edit (tap) and delete (swipe) individual puffs
- Undo/trash functionality with 24-hour recovery window
- CSV export for data backup and analysis
- Daily reminder notifications with configurable time
- Automatic persistence via UserDefaults

**Testing:** 109 tests covering models, grouping logic, goal settings, edit/delete, statistics, streaks, undo/trash, CSV export, and notifications.

### Project Structure

```
Puffwise/
├── Puffwise.xcodeproj/     # Xcode project configuration
├── Puffwise/
│   ├── PuffwiseApp.swift       # App entry point with @main
│   ├── ContentView.swift       # Main UI view with NavigationStack and statistics display
│   ├── HistoryView.swift       # Historical puff tracking view with edit/delete and trash access
│   ├── EditPuffView.swift      # Edit puff timestamp UI with DatePicker
│   ├── TrashView.swift         # Trash/undo view for deleted puffs with restore functionality
│   ├── GoalSettingsView.swift  # Goal settings UI with @AppStorage
│   ├── Puff.swift              # Data model for puff tracking (Codable, Identifiable, Equatable)
│   ├── DeletedPuff.swift       # Data model for trashed puffs with 24-hour expiry
│   ├── PuffGrouping.swift      # Data grouping utilities (day/week/month)
│   ├── StatisticsCalculator.swift  # Statistics calculation (7-day/30-day averages)
│   ├── StreakCalculator.swift  # Streak calculation logic
│   ├── CSVExporter.swift       # CSV export for data backup
│   ├── NotificationManager.swift   # Daily reminder notification scheduling
│   ├── Assets.xcassets/        # App icons and colors
│   └── Preview Content/        # SwiftUI preview assets
└── PuffwiseTests/
    └── PuffwiseTests.swift  # Comprehensive test suite (98 tests)
```

### Build Commands

```bash
# Build the project
cd Puffwise
xcodebuild -project Puffwise.xcodeproj -scheme Puffwise -destination 'generic/platform=iOS Simulator' build

# Run tests
xcodebuild test -project Puffwise.xcodeproj -scheme Puffwise -destination 'platform=iOS Simulator,name=iPhone 16'

# Or open in Xcode
open Puffwise.xcodeproj
```

### Technical Details

- **Min iOS Version**: 17.0
- **Bundle ID**: com.puffwise.app
- **Data Persistence**: UserDefaults with JSON encoding
- **Data Visualization**: Swift Charts (iOS 17.0+)
- **Testing**: Swift Testing framework (Swift 5.9+)
