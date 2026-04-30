#!/bin/bash
# Hook: SessionStart dev environment pre-flight check
# Reports Docker, postgres, redis, and API status so Claude knows the state upfront
# instead of discovering mid-task that Docker isn't running.

set -u

REPORT=""

append() {
  REPORT="${REPORT}${1}\n"
}

# Docker daemon
if ! docker info >/dev/null 2>&1; then
  append "Docker: NOT RUNNING — start Docker Desktop before dev/E2E work"
  echo -e "$REPORT"
  exit 0
fi
append "Docker: running"

# Postgres (port 65432 per CLAUDE.md)
if nc -z localhost 65432 2>/dev/null; then
  append "Postgres (65432): up"
else
  append "Postgres (65432): DOWN — run 'bun dx start' to bring up containers"
fi

# Redis (port 16379 per CLAUDE.md)
if nc -z localhost 16379 2>/dev/null; then
  append "Redis (16379): up"
else
  append "Redis (16379): DOWN — run 'bun dx start' to bring up containers"
fi

# API (check docker port 4611 then native 4410)
if nc -z localhost 4611 2>/dev/null; then
  append "API (4611, docker): up"
elif nc -z localhost 4410 2>/dev/null; then
  append "API (4410, native): up"
else
  append "API: not responding on 4611 or 4410 (ok if not needed this session)"
fi

# Frontend (4200)
if nc -z localhost 4200 2>/dev/null; then
  append "Frontend (4200): up"
else
  append "Frontend (4200): down (ok if not needed this session)"
fi

echo -e "Dev environment pre-flight:\n${REPORT}"
exit 0
