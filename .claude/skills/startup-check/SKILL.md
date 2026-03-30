# Startup Check Skill

Usage: `/startup-check`
Purpose: Restore sprint context and verify the environment at the start of a session

---

## Process

### 1. Restore Context

Check for saved sprint state:

```bash
cat /Users/josephbarkie/Coding/puffwise/.claude/sprint_status.json 2>/dev/null
```

If status is "active":
- Display the saved sprint context (branch, goal, completed tasks, next step)
- Ask the user: "Resume Sprint N from [last step]?"

If no active sprint:
- Confirm: "No active sprint. Ready to start a new sprint or continue backlog work."

### 2. Environment Check

```bash
# Verify Xcode
xcodebuild -version

# Verify git state
git status
git branch --show-current
```

### 3. Quick Build Check (optional)

If resuming mid-sprint, confirm the project still builds:

```bash
xcodebuild -project Puffwise/Puffwise.xcodeproj \
  -scheme Puffwise \
  -destination 'generic/platform=iOS Simulator' \
  build 2>&1 | tail -5
```

### 4. Report

```
[CONTEXT] [Restored: Sprint N / Fresh start]
[BRANCH]  [current branch]
[BUILD]   [PASS/SKIPPED]

Ready for: [next action]
```

---
