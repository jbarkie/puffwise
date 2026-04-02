# Sprint Planning

Last Updated: 2026-03-29
Audience: Product Owner and Claude Code development team
Purpose: Defines sprint structure, team roles, and task decomposition methodology

---

## Sprint Structure

Each sprint is focused on one cohesive enhancement or feature. Sprints consist of:

- **GitHub Cards**: Main deliverables (2-4 per sprint), each with measurable acceptance criteria
- **Tasks**: Focused work units (2-4 hours each), assigned to a specific Claude model
- **Sprint Goal**: One sentence describing the user value delivered

### Acceptance Criteria Rules

Acceptance criteria MUST be:
- Quantifiable and measurable
- Verifiable in the iOS Simulator or via automated test

Avoid subjective terms like "works well", "comprehensive", or "user-friendly".

Example (good): "Today's count widget updates within 1 second of logging a puff in the main app"
Example (bad): "Widget displays puff data nicely"

---

## Team Roles

| Role | Assigned To |
|------|-------------|
| Product Owner | Joseph Barkie |
| Scrum Master | Joseph Barkie |
| Agile Coach | Joseph Barkie |
| Architect | Claude (Sonnet / Opus) |
| Developer | Claude (Haiku / Sonnet) |
| Test Engineer | Claude (Haiku / Sonnet) |

---

## Model Assignment

Use the complexity scoring matrix in `docs/MODEL_ASSIGNMENT_HEURISTICS.md`.

### Assignment Guidelines

**Haiku** (straightforward tasks, ~70% of work):
- Simple UI components and SwiftUI views
- Straightforward CRUD operations on existing models
- Test file updates for existing patterns
- Documentation and comment updates

**Sonnet** (complex tasks, ~25% of work):
- Architectural changes (new data models, protocols)
- Cross-cutting refactoring across multiple files
- Integration work (HealthKit, CloudKit, notifications)
- New view hierarchies with state management

**Opus** (critical tasks, ~5% of work):
- Deep debugging of non-obvious issues
- Novel algorithm design (e.g., streak calculation edge cases)
- Performance-critical code paths
- Security-sensitive changes

---

## Sprint Duration

Sprints are time-boxed but not calendar-fixed. A sprint ends when:
- All tasks are complete and reviewed (normal completion), OR
- A stopping criterion is triggered (see `docs/SPRINT_STOPPING_CRITERIA.md`)

Typical sprint duration: 1-4 hours of Claude execution time.

---

## Xcode Project Registration

Whenever a sprint task creates a new Swift source file, add an explicit sub-task for registering it in `Puffwise.xcodeproj/project.pbxproj`. This requires three edits to the project file:

1. A `PBXFileReference` entry
2. A `PBXBuildFile` entry
3. An entry in the `PBXSourcesBuildPhase` sources list

Assign this sub-task to **Haiku** (Score ~5 — mechanical, 1 file, familiar pattern). Omitting it causes a build failure that blocks subsequent tasks.

---

## Naming Conventions

- **Branch**: `feature/YYYYMMDD_Sprint_N` (e.g., `feature/20260329_Sprint_2`)
- **Sprint file**: `docs/retrospectives/SPRINT_N_RETROSPECTIVE.md`
- **Commit messages**: `type: description (#issue)` — no contractions in messages

---
