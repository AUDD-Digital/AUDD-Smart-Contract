# Read Issue

Read a GitHub issue, understand the problem, research the codebase, and produce a validated fix plan.

## Arguments

The argument is a GitHub issue number, optionally prefixed with `#`. Examples: `#454`, `454`.

## Steps

### 1. Parse the issue number

Strip any leading `#` from the argument to get the issue number.

### 2. Read the GitHub issue

Run `gh issue view <number>` to read the issue title, body, labels, and comments.

- Check for image attachment URLs matching `https://github.com/user-attachments/assets/<asset-id>`. Download these with `gh-asset download <asset-id> ./screenshots/` and view them to understand the bug visually.
- Check the issue labels and timeline for signs this issue has been **reopened**. If reopened, also run:
  ```
  gh issue timeline <number>
  ```
  to understand the history.

### 3. Check for prior fix attempts (reopened issues)

If this issue was previously closed and reopened:

1. Search for PRs that reference this issue:
   ```
   gh pr list --search "<number>" --state merged --json number,title,headRefName,mergeCommit --jq '.[]'
   ```
2. For each merged PR found, read the commits and changes to understand what was previously tried:
   ```
   gh pr view <pr-number> --json commits,files
   gh pr diff <pr-number>
   ```
3. Summarise what the previous fix attempted and why it may have been insufficient.

### 4. Research the codebase

Call `/research_codebase` with a clear description of the problem derived from the issue. The research question should include:

- What the bug or feature request is
- Any specific files, components, or error messages mentioned in the issue
- What the previous fix attempted (if reopened)
- What areas of the codebase need to be investigated

Wait for the research to complete before proceeding.

### 5. Formulate the fix plan

Based on the issue details and codebase research, write a fix plan to `thoughts/fix-<number>.md` containing:

- **Issue summary**: What the problem is, with reproduction steps if available
- **Root cause**: What is causing the issue in the code
- **Prior attempts**: What was tried before and why it didn't work (if reopened)
- **Proposed fix**: Specific files and changes needed to fix the issue
- **Test plan**: What tests to create or update to verify the fix, including:
  - Unit tests for changed logic
  - Integration tests if the fix spans modules
  - Edge cases that should be covered

### 6. Validate the plan

Call `/validate_plan` with the path `thoughts/fix-<number>.md` to check:

- Will the fix actually resolve the issue?
- Could the fix introduce new bugs or regressions?
- Will any existing tests break?
- Are the planned tests sufficient?

Wait for validation to complete.

### 7. Report findings

Present to the user:

1. **Issue summary** — what the problem is
2. **Root cause** — what is causing it
3. **Prior attempts** — what was tried before (if reopened)
4. **Proposed fix** — what changes are needed
5. **Validation result** — any concerns or impacts from the fix
6. **Test plan** — what tests will be created or updated

Ask the user if they would like to proceed with the fix using `/implement_plan thoughts/fix-<number>.md`.

## Rules

- Always read the full issue including comments before researching.
- Always download and view attached screenshots — visual context is critical for UI bugs.
- For reopened issues, understanding the prior fix is mandatory before proposing a new one.
- Never skip the validation step.
- Write the plan to `thoughts/` — it is not permanent documentation.
- Do not start implementing — only plan and validate. The user decides when to implement.
