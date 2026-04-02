# Sprint 2 Retrospective

Date: 2026-04-01
Branch: feature/20260331_Sprint_2
Sprint Goal: Implement compounding weekly goal reduction with a dynamic daily allowance and home screen trajectory chart.

## Outcomes

| Card | Acceptance Criteria | Status |
|------|---------------------|--------|
| Card 1: Reduction Plan Model | ReductionPlan Codable; weeklyTarget compounding formula correct; effectiveDailyGoal distributes remaining budget across remaining days; JSON round-trip | PASS |
| Card 2: Auto-Update Logic | activeGoal drives display and streak calculation; widget synced via shared container on launch | PASS |
| Card 3: Settings UI | Toggle, % stepper, floor stepper persist; plan created on enable; status row shows week and next reduction date | PASS |
| Card 4: Trajectory Chart | LineMark chart on home screen; RuleMark on current week; hidden when mode off | PASS |

## 12-Category Evaluation

1. **Sprint Goal Achievement** — PARTIAL: Feature shipped and functional; tests and documentation required user intervention after PR was opened.
2. **Task Execution** — PASS: Correct order, appropriate parallelism. xcodeproj registration gap caught by build failure and resolved without escalation.
3. **Testing Approach** — NEEDS IMPROVEMENT: 27 tests written only after user flagged the omission. One test had a wrong initial expectation. Tests are now comprehensive.
4. **Effort Accuracy** — PASS: Task 2.1 scored 31 (Opus threshold) but Sonnet handled it correctly per the Puffwise patterns table. All other assignments accurate.
5. **Planning Quality** — PASS: Pre-plan Q&A meaningfully improved design (HealthKit pivot, compounding vs. flat, dynamic goal, chart placement). xcodeproj registration and documentation tasks not made explicit.
6. **Model Assignments** — PASS: Haiku for Task 2.3, Sonnet for 2.1/2.2/2.4. All appropriate.
7. **Communication** — PARTIAL: Strong during planning. No doc references or progress updates during execution. User had to prompt for three separate omissions.
8. **Requirements Clarity** — PASS: Acceptance criteria unambiguous. Dynamic goal design resolved during planning, not mid-implementation.
9. **Documentation** — NEEDS IMPROVEMENT: README.md and CLAUDE.md not updated until after user intervention. Retrospective file not created. GitHub issues not created at Phase 3 approval.
10. **Process Issues** — NEEDS IMPROVEMENT: SPRINT_EXECUTION_WORKFLOW.md not consulted during execution. Phases 2, 5, and 7 skipped. Documentation updates required by CLAUDE.md missed entirely.
11. **Risk Management** — PARTIAL: HealthKit pivot and xcodeproj gap handled well. Tests and documentation omissions not self-caught.
12. **Next Sprint Readiness** — PASS: Backlog current. F3 complete. F2 (iCloud Sync) and F4 (Apple Watch) are next candidates.

## Approved Improvements

1. Consult SPRINT_EXECUTION_WORKFLOW.md at the start of each phase during execution — added phase checklist reminder to CLAUDE.md
2. Run xcodebuild test after each individual task, not only at sprint end — behavioral change, no doc update needed
3. Update README.md and CLAUDE.md before opening the PR — added explicit step to Phase 6 in SPRINT_EXECUTION_WORKFLOW.md
4. Run Phase 5 simulator verification before opening the PR — behavioral change, no doc update needed
5. Add xcodeproj file registration as an explicit task whenever a new Swift file is introduced — added to SPRINT_PLANNING.md and MODEL_ASSIGNMENT_HEURISTICS.md
6. Create GitHub issues at Phase 3 approval, before coding begins — behavioral change, no doc update needed

## Lessons Learned

- The workflow docs are the checklist. Execution without referencing them produces the same omissions every sprint. Read each phase header before starting that phase.
- Tests and documentation are part of the definition of done for a task, not optional follow-ups. A task is not complete until its tests are written and passing.
- xcodeproj registration is a required step whenever a new Swift file is created and must be an explicit task in the sprint plan, not an implicit assumption.
