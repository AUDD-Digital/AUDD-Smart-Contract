# Generate MR Description

You are tasked with generating a comprehensive merge request description following the repository's standard template.

## Steps to follow:

1. **Read the MR description template:**
   - First, check if `thoughts/shared/mr_description.md` exists
   - If it doesn't exist, inform the user that their `humanlayer thoughts` setup is incomplete and they need to create an MR description template at `thoughts/shared/mr_description.md`
   - Read the template carefully to understand all sections and requirements

2. **Identify the MR to describe:**
   - Check if the current branch has an associated MR: `glab mr view --json 2>/dev/null`
   - If no MR exists for the current branch, or if on main/master, list open MRs: `glab mr list --per-page 10`
   - Ask the user which MR they want to describe

3. **Check for existing description:**
   - Check if `thoughts/shared/mrs/{iid}_description.md` already exists (using IID - internal ID)
   - If it exists, read it and inform the user you'll be updating it
   - Consider what has changed since the last description was written

4. **Gather comprehensive MR information:**
   - Get the full MR diff: `glab mr diff {iid}`
   - If you get an error about no default remote repository, instruct the user to run `glab repo set-default` and select the appropriate repository
   - Get commit history: `glab mr view {iid}`
   - Review the base branch: `glab mr view {iid}` (look for target branch)
   - Get MR metadata: `glab mr view {iid}`

5. **Analyze the changes thoroughly:** (ultrathink about the code changes, their architectural implications, and potential impacts)
   - Read through the entire diff carefully
   - For context, read any files that are referenced but not shown in the diff
   - Understand the purpose and impact of each change
   - Identify user-facing changes vs internal implementation details
   - Look for breaking changes or migration requirements

6. **Handle verification requirements:**
   - Look for any checklist items in the "How to verify it" section of the template
   - For each verification step:
     - If it's a command you can run (like `make check test`, `npm test`, etc.), run it
     - If it passes, mark the checkbox as checked: `- [x]`
     - If it fails, keep it unchecked and note what failed: `- [ ]` with explanation
     - If it requires manual testing (UI interactions, external services), leave unchecked and note for user
   - Document any verification steps you couldn't complete

7. **Generate the description:**
   - Fill out each section from the template thoroughly:
     - Answer each question/section based on your analysis
     - Be specific about problems solved and changes made
     - Focus on user impact where relevant
     - Include technical details in appropriate sections
     - Write a concise changelog entry
   - Ensure all checklist items are addressed (checked or explained)

8. **Save and sync the description:**
   - Write the completed description to `thoughts/shared/mrs/{iid}_description.md`
   - Run `humanlayer thoughts sync` to sync the thoughts directory
   - Show the user the generated description

9. **Update the MR:**
   - Update the MR description directly: `glab mr update {iid} --description "$(cat thoughts/shared/mrs/{iid}_description.md)"`
   - Confirm the update was successful
   - If any verification steps remain unchecked, remind the user to complete them before merging

## Important notes:
- This command works across different repositories - always read the local template
- Be thorough but concise - descriptions should be scannable
- Focus on the "why" as much as the "what"
- Include any breaking changes or migration notes prominently
- If the MR touches multiple components, organize the description accordingly
- Always attempt to run verification commands when possible
- Clearly communicate which verification steps need manual testing