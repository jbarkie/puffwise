# Sprint Stopping Criteria

Last Updated: 2026-03-29
Audience: Claude Code development team
Purpose: Defines when to pause work and escalate to the Product Owner

---

## Core Decision Rule

Ask: "Does this decision enable meeting the task's acceptance criteria?"

- **Yes** → proceed independently
- **No** → this constitutes a scope change requiring user approval

---

## Stop Conditions (Pause and Notify User)

1. **Normal Completion**: All sprint tasks are done, tested, and ready for Phase 7 review
2. **Blocked**: Cannot proceed without external input (e.g., missing API key, unclear requirement)
3. **Scope Change Detected**: The sprint plan must change to meet the goal — not just an implementation choice
4. **Bug Discovery (Severe)**: Found a critical regression in existing functionality not related to sprint work
5. **Design Failure**: Fundamental architectural issue requires redesign before proceeding
6. **Context Limit (95%+)**: Commit all in-progress work and notify user before session ends
7. **Early Review Requested**: User explicitly asks for a sprint review before completion
8. **Phase 7 Complete**: Retrospective done, PR created, improvements approved — sprint is closed

---

## Do NOT Stop For

- Implementation choices within the accepted scope (e.g., which SwiftUI modifier to use)
- Single test failures that are immediately debuggable
- Code style decisions covered by existing conventions
- Minor refactors needed to complete a task cleanly
- Choosing between equivalent patterns (both are valid Swift/SwiftUI)

---

## Context Limit Protocol

- At **85% token usage**: Run `/compact` to compress context; continue working
- At **95% token usage**: Commit all in-progress work with clear WIP message, save memory via `/memory-save`, notify user

---

## Bug Severity Guide

| Severity | Description | Action |
|----------|-------------|--------|
| P0 | App crashes or data loss | Stop immediately, notify user |
| P1 | Core feature broken (puff logging, goal tracking) | Stop, notify user |
| P2 | Non-core feature broken (CSV export, etc.) | Log it, finish sprint, report in Phase 7 |
| P3 | Visual glitch, minor UX issue | Note in retrospective, do not stop |

---
