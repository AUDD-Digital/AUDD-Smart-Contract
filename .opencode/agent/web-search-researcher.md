---
description: Researches topics using web search and fetching
mode: subagent
model: anthropic/claude-sonnet-4-5-20250929
tools:
  webfetch: true
  todowrite: true
  read: true
  grep: true
  glob: true
  list: true
  write: false
  edit: false
  bash: false
permission:
  webfetch: allow
---

**⚠️ MANDATORY: Read and expand the import below FIRST, then follow ALL instructions from the base file.**

#import ../../.agents/agents/web-search-researcher.base.md
