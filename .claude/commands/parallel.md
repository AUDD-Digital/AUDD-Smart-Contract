# Parallel Agent Orchestration

Coordinate parallel implementation across multiple git worktrees using Claude agents.

## Input

The user provides either:

- A list of workstreams with descriptions (inline or as arguments)
- A plan file path containing workstream definitions

## Steps

### Phase 1: Setup

1. Run `git branch --show-current` and confirm we're on `dev` (or the base branch). Pull latest: `git pull origin dev`.
2. Parse the workstreams from the arguments or plan file.
3. For each workstream, create a worktree:

   ```bash
   git worktree add .claude/worktrees/ws-<name> -b feat/<name> dev
   ```

4. Confirm all worktrees created: `git worktree list`

### Phase 2: Dispatch

1. Spawn a Task agent (subagent_type: "general-purpose") for each workstream with `isolation: "worktree"`. Each agent receives:

   - The specific task description
   - These isolation rules in the prompt:

     ```markdown
     ISOLATION RULES:
     - Before EVERY git operation, verify your branch with `git branch --show-current`
     - Before committing, run `git diff --name-only` and verify ALL changed files are relevant to your task
     - Run `bun run check:fix` before committing
     - Run relevant tests before committing
     - Commit with conventional commit messages: feat(<scope>): <description>
     - Push your branch when done: git push -u origin feat/<name>
     ```

2. Run agents in parallel where workstreams are independent. Run sequentially if there are dependencies.

### Phase 3: Verify

1. After ALL agents complete, verify each workstream:

   ```bash
   git log --oneline dev..feat/<name>    # confirm only expected commits
   git diff --stat dev..feat/<name>      # confirm only expected files changed
   ```

2. Check for cross-contamination: identify any file that appears in more than one workstream's diff. Flag conflicts.
3. Report results:
   - Which workstreams completed successfully
   - Which had issues
   - Any files that overlap between workstreams
   - Next steps (merge order, conflict resolution needed)

### Phase 4: PRs

1. For each workstream, create a PR targeting `dev`:

    ```bash
    gh pr create --base dev --head feat/<name> --title "feat(<scope>): <description>" --body "$(cat <<'EOF'
    ## Summary
    <bullets from commit log>

    ## Test plan
    - [ ] CI passes
    - [ ] <workstream-specific checks>

    🤖 Generated with [Claude Code](https://claude.com/claude-code)
    EOF
    )"
    ```

2. Report all PR URLs so the user can review and merge them in order.
3. Clean up worktrees after PRs are created: `git worktree remove .claude/worktrees/ws-<name>` for each.

## Rules

- Never merge directly into dev — always use PRs.
- If a workstream agent fails, report the failure but continue with other workstreams.
- Always verify branch isolation before creating PRs.
- Suggest a merge order if workstreams have dependencies.

ARGUMENTS: $ARGUMENTS
