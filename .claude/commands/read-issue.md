# Read Issue

Read a Jira issue, understand the problem, research the codebase, and produce a validated fix plan.

## Arguments

The argument is a Jira issue key in the format `PROJECT-NUMBER`. Examples: `PROJ-454`, `STAB-123`.

## Steps

### 1. Parse the issue key

Use the argument as-is. Validate it matches the `PROJECT-NUMBER` format. If only a number was passed, ask the user for the full issue key — Jira requires the project prefix.

### 2. Read the Jira issue

Run `acli jira workitem view <key>` to read the issue summary, description, status, labels, and fields.

- To include comments and full field detail, run:
  ```
  acli jira workitem view <key> --fields all
  ```
- Check the issue description and comments for image attachments. Jira attachments are referenced by filename. Download them with:
  ```
  acli jira workitem attachment download <key> --output ./screenshots/
  ```
  Then view the downloaded files to understand the bug visually.
- Check the issue status history for signs this issue has been **reopened** (e.g., transitions back from Done/Closed to In Progress). Inspect the changelog with:
  ```
  acli jira workitem view <key> --fields changelog
  ```

### 3. Check for prior fix attempts (reopened issues)

If this issue was previously closed and reopened:

1. Search git log for commits that reference the issue key:
   ```
   git log --all --grep="<key>" --oneline
   ```
2. For each matching commit, inspect the changes:
   ```
   git show <sha>
   ```
3. If the project uses GitLab merge requests, search for merged MRs that reference the issue key in their title or description (the Jira key is typically embedded in branch names and MR titles).
4. Summarise what the previous fix attempted and why it may have been insufficient.

### 4. Research the codebase

Call `/research_codebase` with a clear description of the problem derived from the issue. The research question should include:

- What the bug or feature request is
- Any specific files, components, or error messages mentioned in the issue
- What the previous fix attempted (if reopened)
- What areas of the codebase need to be investigated

Wait for the research to complete before proceeding.

### 5. Formulate the fix plan

Based on the issue details and codebase research, write a fix plan to `thoughts/fix-<key>.md` containing:

- **Issue summary**: What the problem is, with reproduction steps if available
- **Root cause**: What is causing the issue in the code
- **Prior attempts**: What was tried before and why it didn't work (if reopened)
- **Proposed fix**: Specific files and changes needed to fix the issue
- **Test plan**: What tests to create or update to verify the fix, including:
  - Unit tests for changed logic
  - Integration tests if the fix spans modules
  - Edge cases that should be covered

### 6. Validate the plan

Call `/validate_plan` with the path `thoughts/fix-<key>.md` to check:

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

Ask the user if they would like to proceed with the fix using `/implement_plan thoughts/fix-<key>.md`.

## Rules

- Always read the full issue including comments before researching.
- Always download and view attached screenshots — visual context is critical for UI bugs.
- For reopened issues, understanding the prior fix is mandatory before proposing a new one.
- Never skip the validation step.
- Write the plan to `thoughts/` — it is not permanent documentation.
- Do not start implementing — only plan and validate. The user decides when to implement.
- If `acli` is not authenticated, prompt the user to run `acli jira auth login` before proceeding.
