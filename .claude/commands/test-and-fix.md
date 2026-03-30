# Test and Fix Command

Purpose: Run the test suite and systematically resolve failures

---

## Step 1: Run Tests

```bash
xcodebuild test \
  -project Puffwise/Puffwise.xcodeproj \
  -scheme Puffwise \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "(PASS|FAIL|error:|warning:)"
```

## Step 2: Triage Failures

For each failing test:
1. Read the failure message — what assertion failed?
2. Locate the test in `PuffwiseTests/PuffwiseTests.swift`
3. Identify the production code being tested
4. Determine: is this a test bug or a production bug?

## Step 3: Fix

- Fix production code bugs first
- Only update test expectations if the old expectation was wrong
- Do not delete tests to make them pass

## Step 4: Re-run

Re-run the full suite after each fix. Do not batch fixes speculatively.

## Step 5: Report

```
Tests before: N passing, M failing
Tests after:  N+M passing, 0 failing

Fixes applied:
- [file]: [what was wrong and what changed]
```

---
