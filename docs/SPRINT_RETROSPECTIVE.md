# Sprint Retrospective Process

Last Updated: 2026-03-29
Audience: Claude Code development team and Product Owner
Purpose: Mandatory post-sprint review structure ensuring continuous improvement

---

## Overview

Phase 7 is required for every sprint. No PR should be merged without completing this phase. The retrospective takes 30-60 minutes and produces a retrospective file and approved improvements.

---

## 12-Category Evaluation

Rate each category: [PASS], [PARTIAL], or [NEEDS IMPROVEMENT]

1. **Sprint Goal Achievement**: Were all acceptance criteria met? Any partial completions?
2. **Task Execution**: Did tasks complete within estimated effort? Where did estimates miss?
3. **Testing Approach**: Did tests adequately cover new behavior? Any gaps?
4. **Effort Accuracy**: How close were model assignments to actual complexity?
5. **Planning Quality**: Were Cards well-scoped? Would smaller or larger scope have worked better?
6. **Model Assignments**: Did Haiku/Sonnet/Opus assignments match actual task needs?
7. **Communication**: Was the "think out loud" approach sufficient? Any surprises?
8. **Requirements Clarity**: Were acceptance criteria clear enough to execute without clarification?
9. **Documentation**: Was `ALL_SPRINTS_MASTER_PLAN.md` and `CLAUDE.md` kept current?
10. **Process Issues**: Any workflow friction? Steps that felt unnecessary or missing?
11. **Risk Management**: Were unexpected issues handled well? Any near-misses?
12. **Next Sprint Readiness**: Is the backlog prioritized? Are next sprint candidates well-defined?

---

## Improvement Recommendations Format

Number recommendations hierarchically so the user can approve by number:

```
1. [Category: Model Assignments] Promote notification-related tasks to Sonnet by default
   1.1. Update MODEL_ASSIGNMENT_HEURISTICS.md NotificationManager pattern
   1.2. Add note in SPRINT_PLANNING.md for HealthKit/notification work

2. [Category: Testing] Add UI tests for critical puff logging path
   2.1. Create XCTest UI test for ContentView puff button
```

User approves by responding: "Approve 1, 2.1" (or "Approve all")

---

## Required Documentation Updates After Phase 7

- [ ] `docs/ALL_SPRINTS_MASTER_PLAN.md` — Record sprint outcome, duration, lessons learned
- [ ] `docs/MODEL_ASSIGNMENT_HEURISTICS.md` — Update success rates if assignments were off
- [ ] `CLAUDE.md` — Apply any approved workflow improvements
- [ ] Create `docs/retrospectives/SPRINT_N_RETROSPECTIVE.md`

---

## Retrospective File Template

Save as `docs/retrospectives/SPRINT_N_RETROSPECTIVE.md`:

```markdown
# Sprint N Retrospective

Date: YYYY-MM-DD
Duration: X hours
Branch: feature/YYYYMMDD_Sprint_N
Sprint Goal: [one sentence]

## Outcomes

| Card | Acceptance Criteria | Status |
|------|---------------------|--------|
| Card 1 | [criteria] | [PASS/PARTIAL/FAIL] |

## 12-Category Evaluation

[ratings for each category]

## Approved Improvements

[numbered list of approved items]

## Lessons Learned

[2-3 bullet points for future reference]
```

---
