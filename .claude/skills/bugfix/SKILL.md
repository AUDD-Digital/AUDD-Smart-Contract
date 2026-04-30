# Bug Fix Skill

Two phases. Do not collapse them. The phase-1 output is what prevents the bug from reopening.

## Phase 1 — Investigate (no code changes)

1. `gh issue view <number>` — read the issue
2. Download attached images via `gh-asset download <asset-id> ./screenshots/` and view them
3. Reproduce the bug locally if feasible. Capture the actual failure (stack trace, network response, console output) — do not rely on the issue description alone
4. **Trace the full data path.** For any field, enum, DTO, or type involved:
   - `grep` the identifier across `backend/`, `frontend/admin/`, `frontend/microsite/`
   - Walk entity → service → DTO → controller → query hook → component
   - List every touchpoint that reads or writes the value
5. **Write a short trace document** (can be inline in chat) containing:
   - Root cause in one sentence
   - Every file:line that needs to change
   - Every related symbol that could harbour the same bug shape
   - Assumptions you couldn't verify
6. Stop. Confirm the trace with the user before implementing if the blast radius is non-obvious (multi-layer DTO changes, enum renames, shared type edits).

## Phase 2 — Implement

7. Create a clean worktree: `git worktree add ../fix-<issue> dev`
8. Apply the fix to every file listed in the trace — not just the first site
9. **Cascade check before committing:**
   - For every changed identifier (field name, enum value, type name), grep the whole monorepo and confirm no stale references remain
   - For DTO/interface changes, confirm the shape matches across backend response, frontend hook, and consuming component
10. Run tests IN the worktree: `bun test` + relevant frontend tests
11. `bun run check:fix`
12. Commit, push, create PR via `/pr`
13. Clean up: `git worktree remove ../fix-<issue>` (only your own worktree)

## Anti-patterns

- **Fixing the first symptom and stopping.** Bugs in DTOs, enums, and shared types almost always manifest at multiple layers. One fix commit per bug should be the norm; multiple fix commits on the same issue means Phase 1 was skipped.
- **Trusting mocked tests.** If the bug was in a data shape, a passing mocked unit test proves nothing. Verify with an integration test or a manual reproduction against real data.
- **Referencing files from other worktrees.** Each fix must be self-contained in its own worktree.
