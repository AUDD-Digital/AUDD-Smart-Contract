#!/bin/bash
# Hook: Lightweight type-check after Claude finishes responding
# Runs on Stop event to catch TypeScript errors before they compound
# Only checks if .ts files have been modified

cd "$CLAUDE_PROJECT_DIR"

# Get list of changed .ts files (staged + unstaged)
CHANGED_TS=$(git diff --name-only --diff-filter=ACMR HEAD 2>/dev/null | grep '\.ts$' | head -20)

if [ -z "$CHANGED_TS" ]; then
  exit 0
fi

# Check if changes are in backend or frontend and run appropriate type check
HAS_BACKEND=$(echo "$CHANGED_TS" | grep '^backend/' | head -1)
HAS_FRONTEND=$(echo "$CHANGED_TS" | grep '^frontend/' | head -1)

if [ -n "$HAS_BACKEND" ]; then
  ERRORS=$(cd backend && bunx tsc --noEmit --pretty 2>&1 | head -30)
  if [ $? -ne 0 ]; then
    echo "$ERRORS"
    echo ""
    echo "TypeScript errors detected in backend. Review above before committing."
  fi
fi

if [ -n "$HAS_FRONTEND" ]; then
  ERRORS=$(cd frontend/admin && bunx tsc --noEmit --pretty 2>&1 | head -30)
  if [ $? -ne 0 ]; then
    echo "$ERRORS"
    echo ""
    echo "TypeScript errors detected in frontend. Review above before committing."
  fi
fi

exit 0
