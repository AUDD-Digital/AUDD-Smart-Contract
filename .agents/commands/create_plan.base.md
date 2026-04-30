# Implementation Plan

You are tasked with creating detailed implementation plans through an interactive, iterative process. You should be skeptical, thorough, and work collaboratively with the user to produce high-quality technical specifications.

## Initial Response

When this command is invoked:

1. **Check if parameters were provided**:
   - If a file path or ticket reference was provided as a parameter, skip the default message
   - Immediately read any provided files FULLY
   - Begin the research process

2. **If no parameters provided**, respond with:
```
I'll help you create a detailed implementation plan. Let me start by understanding what we're building.

Please provide:
1. The task/ticket description (or reference to a ticket file)
2. Any relevant context, constraints, or specific requirements
3. Links to related research or previous implementations

I'll analyze this information and work with you to create a comprehensive plan.

Tip: You can also invoke this command with a ticket file directly: `/create_plan thoughts/shared/tickets/FSC-1234.md`
For deeper analysis, try: `/create_plan think deeply about thoughts/shared/tickets/FSC-1234.md`
```

Then wait for the user's input.

## Process Steps

### Step 1: Context Gathering & Initial Analysis

1. **Read all mentioned files immediately and FULLY**:
   - Ticket files (e.g., `thoughts/shared/tickets/FSC-1234.md`)
   - Research documents
   - Related implementation plans
   - Any JSON/data files mentioned
   - **IMPORTANT**: Use the Read tool WITHOUT limit/offset parameters to read entire files
   - **CRITICAL**: DO NOT spawn sub-tasks before reading these files yourself in the main context
   - **NEVER** read files partially - if a file is mentioned, read it completely

2. **Spawn initial research tasks to gather context**:
   Before asking the user any questions, use specialized agents to research in parallel:

   - Use the **codebase-locator** agent to find all files related to the ticket/task
   - Use the **codebase-analyzer** agent to understand how the current implementation works
   - If relevant, use the **thoughts-locator agent** to find any existing thoughts documents about this feature
   - If a Linear ticket is mentioned, use the **linear**  to get full details

   These agents will:
   - Find relevant source files, configs, and tests
   - Identify the specific directories to focus on (e.g., if a microservice is mentioned, focus on `apps/[service-name]/`)
   - Trace data flow and key functions
   - Return detailed explanations with file:line references

3. **Read all files identified by research tasks**:
   - After research tasks complete, read ALL files they identified as relevant
   - Read them FULLY into the main context
   - This ensures you have complete understanding before proceeding

4. **Analyze and verify understanding**:
   - Cross-reference the ticket requirements with actual code
   - Identify any discrepancies or misunderstandings
   - Note assumptions that need verification
   - Determine true scope based on codebase reality

5. **Present informed understanding and focused questions**:
   ```
   Based on the ticket and my research of the codebase, I understand we need to [accurate summary].

   I've found that:
   - [Current implementation detail with file:line reference]
   - [Relevant pattern or constraint discovered]
   - [Potential complexity or edge case identified]

   Questions that my research couldn't answer:
   - [Specific technical question that requires human judgment]
   - [Business logic clarification]
   - [Design preference that affects implementation]
   ```

   Only ask questions that you genuinely cannot answer through code investigation.

### Step 2: Research & Discovery

After getting initial clarifications:

1. **If the user corrects any misunderstanding**:
   - DO NOT just accept the correction
   - Spawn new research tasks to verify the correct information
   - Read the specific files/directories they mention
   - Only proceed once you've verified the facts yourself

2. **Create a research todo list** using TodoWrite to track exploration tasks

3. **Spawn parallel sub-tasks for comprehensive research**:
   - Create multiple Task agents to research different aspects concurrently
   - Use the right agent for each type of research:

   **For deeper investigation:**
   - **codebase-locator** - To find more specific files (e.g., "find all files that handle [specific component]")
   - **codebase-analyzer** - To understand implementation details (e.g., "analyze how [system] works")
   - **codebase-pattern-finder** - To find similar features we can model after

   Each agent knows how to:
   - Find the right files and code patterns
   - Identify conventions and patterns to follow
   - Look for integration points and dependencies
   - Return specific file:line references
   - Find tests and examples

4. **Wait for ALL sub-tasks to complete** before proceeding

5. **Present findings and design options**:
   ```
   Based on my research, here's what I found:

   **Current State:**
   - [Key discovery about existing code]
   - [Pattern or convention to follow]

   **Design Options:**
   1. [Option A] - [pros/cons]
   2. [Option B] - [pros/cons]

   **Open Questions:**
   - [Technical uncertainty]
   - [Design decision needed]

   Which approach aligns best with your vision?
   ```

### Step 3: Plan Structure Development

Once aligned on approach:

1. **Create initial plan outline**:
   ```
   Here's my proposed plan structure:

   ## Overview
   [1-2 sentence summary]

   ## Implementation Phases:
   1. [Phase name] - [what it accomplishes]
   2. [Phase name] - [what it accomplishes]
   3. [Phase name] - [what it accomplishes]

   Does this phasing make sense? Should I adjust the order or granularity?
   ```

2. **Get feedback on structure** before writing details

### Step 4: Detailed Plan Writing

After structure approval:

1. **Write the plan** to `thoughts/shared/plans/YYYY-MM-DD-FSC-XXXX-description.md`
   - Format: `YYYY-MM-DD-FSC-XXXX-description.md` where:
     - YYYY-MM-DD is today's date
     - FSC-XXXX is the ticket number (omit if no ticket)
     - description is a brief kebab-case description
   - Examples:
     - With ticket: `2025-10-01-FSC-1478-parent-child-tracking.md`
     - Without ticket: `2025-10-01-improve-error-handling.md`

2. **Use this template structure**:

````markdown
# [Feature/Task Name] Implementation Plan

## Overview

[Brief description of what we're implementing and why]

## Current State Analysis

[What exists now, what's missing, key constraints discovered]

## Desired End State

[A Specification of the desired end state after this plan is complete, and how to verify it]

### Key Discoveries:
- [Important finding with file:line reference]
- [Pattern to follow]
- [Constraint to work within]

## What We're NOT Doing

[Explicitly list out-of-scope items to prevent scope creep]

## Implementation Approach

[High-level strategy and reasoning]

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Changes Required:

#### 1. [Component/File Group]
**File**: `path/to/file.ts`
**Changes**: [Summary of changes]

```typescript
// Specific code to add/modify
```

### Success Criteria:

#### Automated Verification:
- [ ] TypeScript compilation passes: `bun run check`
- [ ] Linting passes: `bun run lint`
- [ ] Database migrations apply cleanly: `bun db:migration run -w [service]`
- [ ] AsyncAPI schemas validate: `bun run schema:validate`
- [ ] Service builds successfully: `docker compose build [service]`
- [ ] Whole system compiles successfully: `docker compose build dev_container`
- [ ] Whole system runs successfully: `docker compose up sys`

#### Manual Verification:
- [ ] Feature works as expected when tested via API
- [ ] NATS events are published correctly
- [ ] Database changes are reflected properly
- [ ] No regressions in related features

---

## Phase 2: [Descriptive Name]

[Similar structure with both automated and manual success criteria...]

---

## Database Migration Notes

### Migration Files:
- Location: `libs/datastore/[service]/migrations/`
- Naming: `YYYYMMDDHHMMSS-descriptive-name.ts`

### Migration Steps:
1. Generate migration: `bun db:migration generate -w [service] -n [migration-name]`
2. Review generated migration
3. Run migration: `bun db:migration run -w [service]`
4. Verify migration: Check database schema
5. Make sure the database package is included in the tsconfig.json

### Rollback Strategy:
- [How to rollback if needed]
- [Data preservation considerations]

## AsyncAPI Schema Updates

### Schema Files:
- Location: `schema/asyncapi/[service].yaml`
- Purpose: [What events/messages are being added/modified]

### Schema Validation:
- Run: `bun run schema:validate`
- Generate types: `bun run schema:generate`
- Make sure the asyncapi package is included in the tsconfig.json

### Events to Define:
- [Event name and purpose]
- [Message structure]
- [Publishing and subscribing services]

## Performance Considerations

[Any performance implications or optimizations needed]

## Security Considerations

- [Authentication/Authorization changes]
- [Data validation requirements]
- [Security best practices to follow]

## Deployment Notes

### Environment Variables:
- [New env vars needed]
- [Configuration changes]

### Service Dependencies:
- [Other services that need to be updated]
- [External dependencies]

### Deployment Order:
1. [First service/component to deploy]
2. [Second service/component to deploy]
3. [Verification steps]

## References

- Original ticket: `thoughts/shared/tickets/FSC-XXXX.md`
- Related research: `thoughts/shared/research/[relevant].md`
- Similar implementation: `[file:line]`
- Documentation: `docs/[relevant].md`
````

### Step 5: Sync and Review

1. **Sync the thoughts directory**:
   - Run `humanlayer thoughts sync` to sync the newly created plan
   - This ensures the plan is properly indexed and available

2. **Present the draft plan location**:
   ```
   I've created the initial implementation plan at:
   `thoughts/shared/plans/YYYY-MM-DD-FSC-XXXX-description.md`

   Please review it and let me know:
   - Are the phases properly scoped?
   - Are the success criteria specific enough?
   - Any technical details that need adjustment?
   - Missing edge cases or considerations?
   ```

3. **Iterate based on feedback** - be ready to:
   - Add missing phases
   - Adjust technical approach
   - Clarify success criteria (both automated and manual)
   - Add/remove scope items
   - After making changes, run `humanlayer thoughts sync` again

4. **Continue refining** until the user is satisfied

## Important Guidelines

1. **Be Skeptical**:
   - Question vague requirements
   - Identify potential issues early
   - Ask "why" and "what about"
   - Don't assume - verify with code

2. **Be Interactive**:
   - Don't write the full plan in one shot
   - Get buy-in at each major step
   - Allow course corrections
   - Work collaboratively

3. **Be Thorough**:
   - Read all context files COMPLETELY before planning
   - Research actual code patterns using parallel sub-tasks
   - Include specific file paths and line numbers
   - Write measurable success criteria with clear automated vs manual distinction

4. **Be Practical**:
   - Focus on incremental, testable changes
   - Consider migration and rollback
   - Think about edge cases
   - Include "what we're NOT doing"

5. **Track Progress**:
   - Use TodoWrite to track planning tasks
   - Update todos as you complete research
   - Mark planning tasks complete when done

6. **No Open Questions in Final Plan**:
   - If you encounter open questions during planning, STOP
   - Research or ask for clarification immediately
   - Do NOT write the plan with unresolved questions
   - The implementation plan must be complete and actionable
   - Every decision must be made before finalizing the plan

## Success Criteria Guidelines

**Always separate success criteria into two categories:**

1. **Automated Verification** (can be run by execution agents):
   - Commands that can be run: `bun test`, `bun run check`, `docker compose build`, etc.
   - Specific files that should exist
   - Code compilation/type checking
   - Automated test suites

2. **Manual Verification** (requires human testing):
   - API/UI functionality
   - Performance under real conditions
   - Edge cases that are hard to automate
   - User acceptance criteria

**Format example:**
```markdown
### Success Criteria:

#### Automated Verification:
- [ ] TypeScript compilation passes: `bun run check`
- [ ] No linting errors: `bun run lint`
- [ ] Database migration applies: `bun db:migration run -w [service]`
- [ ] AsyncAPI schema validates: `bun run schema:validate`
- [ ] Service builds: `docker compose build [service]`

#### Manual Verification:
- [ ] New feature appears correctly in the API response
- [ ] Performance is acceptable with 1000+ items
- [ ] Error messages are clear and helpful
- [ ] NATS events are published and consumed correctly
```

## Common Patterns

### For Database Changes:
1. Create entities in `libs/datastore/[service]/src/entities.ts`
2. Generate migration: `bun db:migration generate -w [service]`
3. Review and modify migration if needed
4. Run migration: `bun db:migration run -w [service]`
5. Add repository methods in service
6. Update business logic
7. Expose via NATS command/query handlers
8. Update AsyncAPI schema
9. Update API gateway DTOs/controllers if needed

### For New Microservices:
1. Research existing patterns first (look at similar services in `apps/`)
2. Create service structure following NestJS patterns
3. Define database entities in `libs/datastore/[service]/`
4. Create AsyncAPI schema in `schema/asyncapi/[service].yaml`
5. Implement NATS command/query/event handlers
6. Add service to `docker-compose.yml`
7. Create Dockerfile
8. Add to `package.json` workspaces
9. Update documentation in `docs/`

### For New Features:
1. Research existing patterns first
2. Start with data model (entities)
3. Build service layer (business logic)
4. Add NATS handlers (commands/queries/events)
5. Update AsyncAPI schema
6. Add API gateway endpoints (if needed)
7. Write unit tests
8. Write integration tests
9. Add E2E tests for critical paths

### For Refactoring:
1. Document current behavior with tests
2. Plan incremental changes
3. Maintain backwards compatibility
4. Ensure NATS event contracts remain stable
5. Include migration strategy for data/events
6. Update AsyncAPI schemas if message structure changes

## Repository-Specific Patterns

### NestJS Service Structure
Each microservice in `apps/[service]/` follows:
```
apps/[service]/
├── src/
│   ├── [service]/
│   │   ├── command.controller.ts  # NATS command handlers
│   │   ├── query.controller.ts    # NATS query handlers
│   │   ├── event.controller.ts    # NATS event handlers (optional)
│   │   ├── [service].service.ts   # Business logic
│   │   └── [service].module.ts    # NestJS module
│   ├── providers/                 # Service providers
│   ├── env.ts                     # Environment config
│   └── main.ts                    # Entry point
├── test/
│   ├── unit/                      # Unit tests
│   └── integration/               # Integration tests
├── Dockerfile
└── package.json
```

### Database Structure
```
libs/datastore/[service]/
├── src/
│   ├── entities.ts                # TypeORM entities
│   └── index.ts                   # Exports
├── migrations/                    # TypeORM migrations
│   └── YYYYMMDDHHMMSS-name.ts
└── package.json
```

### AsyncAPI Schema Structure
```
schema/asyncapi/[service].yaml     # Event definitions
```


### Build and Run Commands
- Build service: `docker compose build [service]`
- Run service: `bun run up [service]`
- Run all services: `docker compose up`
- View logs: `bun run logs [service]`

### Database Commands
- Provision: `bun db:provision up -w [service]`
- Generate migration: `bun db:migration generate -w [service] -n [name]`
- Run migrations: `bun db:migration run -w [service]`
- Seed data: `bun db:seed core -w [service]`

### Code Quality Commands
- Format check: `bun run format`
- Format fix: `bun run format:fix`
- Lint check: `bun run lint`
- Lint fix: `bun run lint:fix`
- Full check: `bun run check`
- Full fix: `bun run check:fix`

## Sub-task Spawning Best Practices

When spawning research sub-tasks:

1. **Spawn multiple tasks in parallel** for efficiency
2. **Each task should be focused** on a specific area
3. **Provide detailed instructions** including:
   - Exactly what to search for
   - Which directories to focus on
   - What information to extract
   - Expected output format
4. **Be EXTREMELY specific about directories**:
   - If the ticket mentions a specific microservice, specify `apps/[service-name]/` directory
   - For database entities, specify `libs/datastore/[service-name]/`
   - For API endpoints, specify `apis/[gateway-name]/`
   - For AsyncAPI schemas, specify `schema/asyncapi/`
   - Include the full path context in your prompts
5. **Specify read-only tools** to use
6. **Request specific file:line references** in responses
7. **Wait for all tasks to complete** before synthesizing
8. **Verify sub-task results**:
   - If a sub-task returns unexpected results, spawn follow-up tasks
   - Cross-check findings against the actual codebase
   - Don't accept results that seem incorrect

Example of spawning multiple tasks:
```typescript
// Spawn these tasks concurrently:
// 1. Research database schema in libs/datastore/[service]/
// 2. Find NATS event patterns in apps/[service]/
// 3. Investigate API gateway patterns in apis/gateway/
// 4. Check AsyncAPI schema in schema/asyncapi/[service].yaml
// 5. Look for similar implementations in other services
```

## Example Interaction Flow

```
User: /create_plan
Assistant: I'll help you create a detailed implementation plan...

User: We need to add activity tracking for user wallet operations. See thoughts/shared/tickets/FSC-1478.md
Assistant: Let me read that ticket file completely first...

[Reads file fully]

Based on the ticket, I understand we need to add activity logging when users perform wallet operations. Let me research the current implementation...

[Spawns research tasks to understand activity service, wallet service, and NATS events]

[After research completes]

Based on my research, I found:
- Activity service exists at `apps/activity/` with command handlers for creating activity records
- Wallet service publishes NATS events at `apps/wallet/src/wallet/event.controller.ts`
- Similar activity tracking exists for asset operations

Before I create a plan, I have a few questions:
- Should we track all wallet operations or only specific ones (create, transfer, etc.)?
- Do we need to support bulk activity creation for batch operations?
- Should activity records be queryable by wallet ID?

[Interactive process continues...]
```

## Documentation References

For comprehensive guidelines, refer to:
- **Repository Structure**: `docs/agent-instructions.md`
- **System Architecture**: `docs/system-overview.md`
- **Microservices Patterns**: `docs/microservices-patterns.md`
- **API Gateway Patterns**: `docs/api-gateway-patterns.md`
- **Pagination Rules**: `docs/pagination-implementation.md`
- **Testing Strategy**: `docs/testing-strategy.md`

## Key Reminders

### Always Consider:
1. **Event-Driven Architecture**: All inter-service communication via NATS
2. **Database Per Service**: Each service owns its data
3. **AsyncAPI Schemas**: Keep event contracts up to date
4. **Type Safety**: Use TypeScript strictly
5. **Error Handling**: Follow NestJS exception patterns
6. **Testing**: Unit, integration, and E2E tests
7. **Documentation**: Update relevant docs when adding features

### Never:
1. Share database access between services
2. Make direct HTTP calls between services (use NATS)
3. Skip AsyncAPI schema updates
4. Leave TODOs in production code
5. Skip error handling
6. Ignore existing patterns
7. Write plans with unresolved questions

