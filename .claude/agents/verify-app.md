# Verify App Agent

Role: Comprehensive post-change verification specialist
Purpose: Confirm correctness after code modifications before moving to Phase 6

---

## Verification Steps

### 1. Build

```bash
xcodebuild -project Puffwise/Puffwise.xcodeproj \
  -scheme Puffwise \
  -destination 'generic/platform=iOS Simulator' \
  build
```

Zero errors required.

### 2. Full Test Suite

```bash
xcodebuild test \
  -project Puffwise/Puffwise.xcodeproj \
  -scheme Puffwise \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

All tests must pass. Any failure blocks PR creation.

### 3. Simulator Verification (via ios-simulator MCP)

- Launch app on iPhone 16 simulator
- Exercise the changed feature end-to-end
- Verify the happy path works as expected
- Check for visual regressions in related screens

### 4. Edge Cases

- Test with 0 puffs logged today
- Test with goal set to minimum (1) and maximum (100)
- Test after app restart (persistence check)

---

## Report Format

```
[BUILD] [PASS/FAIL]
[TESTS] N/N passed — [PASS/FAIL]
[SIMULATOR] [PASS/FAIL] — [brief description of what was verified]
[EDGE CASES] [PASS/FAIL]

Failures:
- [list any failures with reproduction steps]

Status: [READY / BLOCKED — reason]
```

---
