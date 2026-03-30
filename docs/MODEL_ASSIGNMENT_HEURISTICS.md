# Model Assignment Heuristics

Last Updated: 2026-03-29
Audience: Claude Code (sprint planning)
Purpose: Data-driven framework for routing tasks to the right Claude model

---

## Scoring Matrix (0-40 points)

### Cognitive Load (0-20 points)

| Factor | Points |
|--------|--------|
| Simple UI component change | 2 |
| Bug fix with known location | 5 |
| New SwiftUI view (no state) | 8 |
| State management / ObservableObject | 12 |
| New data model or protocol | 15 |
| Architectural decision (cross-cutting) | 20 |

### Risk and Scope (0-10 points)

| Factor | Points |
|--------|--------|
| 1 file affected | 1 |
| 2-3 files affected | 4 |
| 4+ files affected | 8 |
| Core data model affected | +2 |
| Test suite significantly impacted | +2 |

### Pattern Recognition (0-10 points)

| Factor | Points |
|--------|--------|
| Familiar pattern (seen in codebase) | 0 |
| Adapted pattern (similar but not identical) | 5 |
| Novel pattern (no prior example) | 10 |

---

## Assignment Thresholds

| Score | Model | Notes |
|-------|-------|-------|
| 0-15 | Haiku | High confidence (90%+) |
| 16-28 | Sonnet | Medium confidence (80-90%) |
| 29+ | Opus | Lower confidence — deep work needed |

---

## Escalation Triggers

Automatically promote to next model if:
- Test failures after more than 2 attempts at the same approach
- Architectural blocker identified mid-task
- Performance regression introduced
- Cross-cutting concern discovered during implementation
- Security-sensitive code path (UserDefaults encoding, file I/O)

---

## Puffwise-Specific Patterns

| Task Type | Default Model | Reasoning |
|-----------|---------------|-----------|
| SwiftUI view (no state) | Haiku | Follows established patterns |
| @State / @Binding additions | Haiku | Simple, well-understood |
| @ObservableObject changes | Sonnet | State propagation risk |
| UserDefaults read/write | Sonnet | Encoding/decoding edge cases |
| HealthKit / CloudKit | Sonnet | Framework integration complexity |
| New Codable model | Sonnet | Serialization correctness matters |
| Swift Charts updates | Haiku | Declarative, low risk |
| NotificationManager changes | Sonnet | Background scheduling complexity |
| Streak/statistics algorithms | Sonnet | Edge cases, correctness-critical |
| Widget extension work | Sonnet | New target, timeline entry complexity |
| Deep algorithmic debugging | Opus | Root cause analysis |

---

## Performance Tracking

Update this section after each sprint by running `/update-heuristics`.

| Model | Sprints Tracked | Avg Score Accuracy | Success Rate |
|-------|----------------|-------------------|--------------|
| Haiku | 0 | N/A | N/A |
| Sonnet | 0 | N/A | N/A |
| Opus | 0 | N/A | N/A |

*Success = task completed without escalation*

---
