
# All Sprints Master Plan

Last Updated: 2026-04-16
Audience: Product Owner and Claude Code development team
Purpose: Single source of truth for sprint history, current state, and future roadmap

## Maintenance Guidelines

Update this file during:
- **Phase 3** (Sprint Planning): Add new sprint entry with planned Cards
- **Phase 7** (Sprint Review): Fill in actual outcomes, lessons learned, duration
- **Backlog Refinement**: Reprioritize Next Sprint Candidates, add/remove/update items

Do not record implementation details — those belong in retrospective files and commit messages.

---

## Project State

**Platform**: iOS 17.0+
**Language**: Swift / SwiftUI
**Tests**: 109 passing
**Bundle ID**: com.puffwise.app
**Current Sprint**: None active — see Next Sprint Candidates

---

## Foundation (Pre-Sprint History)

The following features were built before the sprint framework was established:

- Puff logging with daily goal tracking (1-100 puffs)
- Statistics display (7-day and 30-day averages)
- Streak tracking with flame icon
- History view with bar charts (day/week/month filtering)
- Edit (tap) and delete (swipe) individual puffs
- Undo/trash with 24-hour recovery window
- CSV export for data backup
- Daily reminder notifications with configurable time
- UserDefaults persistence with JSON encoding
- 109-test suite covering all core features

---

## Completed Sprints

### Sprint 1: Home Screen Widget (2026-03-29)

- **Branch**: feature/daily-count-widget
- **Status**: Completed — merged via PR #26
- **Goal**: Add iOS home screen widget showing today's puff count vs. goal
- **Outcome**: Small widget with circular progress ring, puff count, and on-track status. Shared App Group container for data sharing between app and widget.

### Sprint 2: Reduction Goal Mode (2026-03-31)

- **Branch**: feature/20260331_Sprint_2
- **Status**: Completed — pending PR merge
- **Goal**: Automatic compounding weekly goal reduction with dynamic daily allowance
- **Outcome**: ReductionPlan model with compounding reduction, effective daily goal accounting for puffs already logged in the week, settings UI in GoalSettingsView, and LineMark trajectory chart on the home screen. 144 tests passing (35 new).
- **Lessons Learned**:
  - Read each phase of SPRINT_EXECUTION_WORKFLOW.md before executing it — do not rely on memory
  - Tests and documentation are part of the definition of done; a task is not complete without them
  - New Swift files require explicit xcodeproj registration — make it a named task in the plan

---

## Next Sprint Candidates

### F3. Reduction Goal Mode — COMPLETED Sprint 2

### F6. Onboarding Flow (~5 hrs) Priority 1

- **Phase**: Core App
- **Platform**: iOS
- First-launch walkthrough setting initial goal and notification preference
- Explain puff counting concept and app philosophy
- Skip option for returning users after reinstall

### UI. UI and Design Refresh (~6 hrs) Priority 2

- **Phase**: Core App
- **Platform**: iOS
- Consistent color system and typography across all views
- Improved spacing, visual hierarchy, and layout polish
- Transitions and animations
- Better empty states
- Accessibility improvements

### F2. iCloud Sync (~10 hrs) Priority 3

- **Phase**: Core App
- **Platform**: iOS
- Sync puff data across user's devices via CloudKit
- Replace or supplement UserDefaults with CloudKit private database
- Requires iCloud entitlement and conflict resolution strategy

### F4. Apple Watch Companion (~12 hrs) Priority 4

- **Phase**: Core App
- **Platform**: iOS + watchOS
- WatchKit extension for quick puff logging from wrist
- Complication showing today's count and goal progress
- WatchConnectivity framework for data sync

### F7. App Store Submission (~6 hrs) Terminal Sprint

- **Phase**: Distribution
- **Platform**: iOS
- App Store Connect setup (screenshots, description, metadata)
- Privacy policy and data use declaration
- TestFlight beta before public release

---

## HOLD Items

### H1. Android / Cross-Platform Port (~40 hrs) Priority HOLD

- **Reason**: iOS-first; revisit after App Store launch
- Would require Flutter or React Native rewrite

### H2. Premium / Paywall (~8 hrs) Priority HOLD

- **Reason**: App is intentionally ad-free and simple; monetization not a current goal

### H3. Shareable Progress Cards (~4 hrs) Priority HOLD

- **Reason**: Share cards for routine milestones feel low-value; revisit only for high-significance achievements (e.g., user has quit entirely, 30/60/90-day streak)
- Would require defining achievement thresholds and SwiftUI canvas rendering via UIGraphicsImageRenderer

### H4. HealthKit Integration Priority HOLD

- **Reason**: Explored and ruled out — not sufficiently useful or feasible for this app's scope

---
