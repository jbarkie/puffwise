# Commit, Push, and PR Command

Purpose: Standardized 6-step process for completing a sprint's code delivery

---

## Step 1: Review Changes

```bash
git status
git diff --staged
```

Confirm only sprint-related files are staged.

## Step 2: Verify Standards

- Build passes (zero errors)
- All tests pass
- No `print()` statements left in production code
- No TODOs that block the sprint goal

## Step 3: Stage Files

Stage specific files by name. Never use `git add -A` or `git add .`.

```bash
git add Puffwise/Puffwise/FileName.swift
git add PuffwiseTests/PuffwiseTests.swift
```

## Step 4: Commit

Format: `type: description (#issue)`

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

No contractions in commit messages.

```bash
git commit -m "feat: add daily count home screen widget (#12)"
```

## Step 5: Push

```bash
git push -u origin feature/YYYYMMDD_Sprint_N
```

## Step 6: Create Pull Request

Target: **main** (never skip)

Use the PR template from `CLAUDE.md`. Include:
- Summary (1-3 sentences)
- What Changed (per-file bullet points)
- Swift/SwiftUI Concepts (if new patterns introduced)
- Test Plan checklist

```bash
gh pr create --title "Sprint N: [goal]" --body "$(cat <<'EOF'
## Summary

[...]

## What Changed

- **File.swift**: [...]

## Swift/SwiftUI Concepts

[...]

## Test Plan

- [ ] All tests pass
- [ ] Verified in iOS Simulator via ios-simulator MCP
- [ ] [feature-specific checks]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---
