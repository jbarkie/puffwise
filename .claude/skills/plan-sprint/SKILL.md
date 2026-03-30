# Plan Sprint Skill

Usage: `/plan-sprint [issue number or feature description]`
Purpose: Analyze a feature or GitHub issue and produce a sprint plan with task decomposition and model assignments

---

## Process

### 1. Read Context

- Read `docs/ALL_SPRINTS_MASTER_PLAN.md` for the feature description and priority
- Read `docs/MODEL_ASSIGNMENT_HEURISTICS.md` for scoring criteria
- Read `CLAUDE.md` for project conventions

### 2. Decompose into Tasks

Break the feature into tasks where each task:
- Can be completed in 2-4 hours
- Has a single, clear responsibility
- Has verifiable acceptance criteria
- Maps to specific files in the project

### 3. Score Each Task

Apply the scoring matrix from `docs/MODEL_ASSIGNMENT_HEURISTICS.md`:
- Cognitive load (0-20)
- Risk and scope (0-10)
- Pattern recognition (0-10)
- Total score → model assignment

### 4. Output Plan

Present the plan in this format:

```
## Sprint N: [Goal]

**Branch**: feature/YYYYMMDD_Sprint_N

### Card 1: [Title]
Acceptance Criteria:
- [ ] [measurable criterion]
- [ ] [measurable criterion]

**Task 1.1** [Model: Haiku | Score: 8]
- Files: [list]
- Work: [description]
- Criteria: [what "done" looks like]

**Task 1.2** [Model: Sonnet | Score: 22]
- Files: [list]
- Work: [description]
- Criteria: [what "done" looks like]

### Execution Order
1. Task 1.1
2. Task 1.2

### Confidence
- Task 1.1: 92% (Haiku — familiar pattern)
- Task 1.2: 81% (Sonnet — new ObservableObject integration)

### Risks
- [any identified risks]
```

### 5. Wait for Approval

Present the plan and wait for explicit user approval before beginning Phase 4.

---
