#!/bin/bash
# save-memory.sh
# Save current sprint context before ending a session
# Usage: bash .claude/scripts/save-memory.sh

MEMORY_DIR=".claude/memory"
mkdir -p "$MEMORY_DIR"

echo "Saving sprint context..."

# Gather current state
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Write sprint_status.json
cat > ".claude/sprint_status.json" << EOF
{
  "status": "active",
  "saved_at": "$DATE",
  "branch": "$BRANCH",
  "sprint": "UPDATE THIS FIELD",
  "last_completed_task": "UPDATE THIS FIELD",
  "next_step": "UPDATE THIS FIELD",
  "notes": "UPDATE THIS FIELD"
}
EOF

echo "[OK] Context saved to .claude/sprint_status.json"
echo ""
echo "IMPORTANT: Open .claude/sprint_status.json and fill in:"
echo "  - sprint (e.g., 'Sprint 2: Widget Timeline')"
echo "  - last_completed_task"
echo "  - next_step"
echo "  - notes (any relevant context)"
