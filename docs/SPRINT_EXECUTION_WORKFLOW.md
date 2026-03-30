# Sprint Execution Workflow

Last Updated: 2026-03-29
Audience: Claude Code development team
Purpose: Step-by-step playbook for executing sprints from kickoff through retrospective

---

## Overview

Sprints follow a mandatory 7-phase process. Phases 1 and 7 involve the Product Owner. Phases 2-6 are primarily Claude execution with approval gates at Phase 3.

**Key Principle**: Once the sprint plan is approved in Phase 3, all tasks within that plan are pre-authorized. Do not stop for per-task approval. Only stop for criteria in `SPRINT_STOPPING_CRITERIA.md`.

---

## Phase 1: Backlog Refinement (Optional, On-Demand)

- Triggered explicitly by the user or when priorities have shifted
- Review and reprioritize `docs/ALL_SPRINTS_MASTER_PLAN.md`
- Time-box to 30-60 minutes
- Output: updated Next Sprint Candidates section

See `docs/BACKLOG_REFINEMENT.md` for the full process.

---

## Phase 2: Sprint Pre-Kickoff Verification

Before any code changes:

1. Run `/startup-check` to restore context and verify environment
2. Confirm Xcode and iOS Simulator are available: `xcodebuild -version`
3. Confirm the project builds: `xcodebuild -project Puffwise/Puffwise.xcodeproj -scheme Puffwise -destination 'generic/platform=iOS Simulator' build`
4. Run the full test suite and confirm all tests pass
5. Confirm current branch is clean or create a new feature branch: `git checkout -b feature/YYYYMMDD_Sprint_N`
6. Present environment status to the user and get pre-kickoff approval

---

## Phase 3: Sprint Planning and GitHub Issue Creation

1. Present sprint goal and proposed Cards (2-4 GitHub issues)
2. Break each Card into tasks (2-4 hours each) using `/plan-sprint`
3. Assign each task to a model (Haiku / Sonnet / Opus) per `docs/MODEL_ASSIGNMENT_HEURISTICS.md`
4. Present the full plan with complexity scores and confidence ratings
5. **Wait for explicit user approval**

Once approved:
- All tasks in the sprint are pre-authorized
- Create GitHub issues if applicable
- Update `docs/ALL_SPRINTS_MASTER_PLAN.md` with the new sprint entry

---

## Phase 4: Development and Testing Cycles

Execute tasks in the approved order:

- Follow Swift/SwiftUI conventions in the existing codebase
- Write or update tests for every changed behavior
- Run `xcodebuild test` after each task to verify no regressions
- Batch parallel operations where possible (e.g., updating multiple independent files)
- Think out loud — share investigation process before acting on non-obvious decisions
- Check `SPRINT_STOPPING_CRITERIA.md` if an unexpected issue arises

---

## Phase 5: Code Review and Comprehensive Testing

1. Run the full test suite: `xcodebuild test -project Puffwise/Puffwise.xcodeproj -scheme Puffwise -destination 'platform=iOS Simulator,name=iPhone 16'`
2. Confirm all tests pass (zero failures)
3. Build and install on the iOS Simulator via ios-simulator MCP
4. Visually verify the feature works as expected in the simulator
5. Address any issues found before proceeding

---

## Phase 6: Commit, Push, and PR Creation

Follow the process in `.claude/commands/commit-push-pr.md`:

1. Stage relevant files (specific files, never `git add -A`)
2. Commit with format: `type: description (#issue)` — no contractions
3. Push to feature branch: `git push -u origin feature/YYYYMMDD_Sprint_N`
4. Create PR targeting **main** (never skip this step)
5. PR description follows the template in `CLAUDE.md`

---

## Phase 7: Sprint Review and Retrospective (MANDATORY)

Phase 7 is required for every sprint before the PR is merged.

1. Present sprint outcomes against acceptance criteria
2. Run the 12-category retrospective evaluation (see `docs/SPRINT_RETROSPECTIVE.md`)
3. Generate improvement recommendations; user approves by listing numbers (e.g., "Approve 1, 2.1")
4. Update `docs/ALL_SPRINTS_MASTER_PLAN.md` with sprint outcome and lessons learned
5. Update `CLAUDE.md` if workflow improvements were approved
6. Create `docs/retrospectives/SPRINT_N_RETROSPECTIVE.md`

---

## Context Management

- At 85% token usage: run `/compact` to compress context
- Before ending a session mid-sprint: run `/memory-save` to persist sprint state
- At the start of a session: run `/startup-check` to restore sprint context

---
