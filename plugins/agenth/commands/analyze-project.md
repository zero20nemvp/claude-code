# /analyze-project

## Purpose
Analyze an existing project/codebase and generate a complete WOOP goal structure for AgentH orchestration.

## Usage
```
/analyze-project <path>
```

## Workflow

### 1. Project Analysis
You must comprehensively analyze the project at the given path:

**Code Structure:**
- File organization and architecture
- Implemented vs stubbed functionality
- Code quality and patterns
- Technology stack and frameworks

**Documentation:**
- README files
- Inline documentation
- API docs
- Comment quality

**Git History:**
- Recent commits (last 20-30)
- Active branches
- Work-in-progress indicators
- Development velocity

**Dependencies & Tooling:**
- package.json / requirements.txt / go.mod etc.
- Build configuration
- Testing setup
- Deployment configuration
- CI/CD pipelines

### 2. Generate Current State
Create a comprehensive `current_state` array describing where the project currently stands.

**Format:** Array of clear, factual statements

**Example:**
```json
[
  "Next.js 14 application with App Router configured",
  "Database schema defined with Prisma (5 models)",
  "Authentication implemented using NextAuth.js",
  "3 of 8 planned page routes completed",
  "API endpoints stubbed but not connected to database",
  "No test coverage exists yet",
  "Build pipeline functional, deployment not configured",
  "Basic styling with Tailwind CSS, no component library"
]
```

**Guidelines:**
- Be specific and measurable ("3 of 8 routes" not "some routes done")
- Note what exists vs what's stubbed vs what's missing
- Include technical decisions already made
- Mention blockers or incomplete work
- Reference concrete artifacts (files, configs, dependencies)

### 3. Prompt for Goal Information
Use the AskUserQuestion tool to gather:

**Question 1: Wish**
- "What do you want this project to become?"
- Provide 3-4 example options based on the analysis
- Always include "Other" option

**Question 2: Done When (multiSelect: true)**
- "What are the acceptance criteria for completion?"
- Suggest 3-4 specific criteria based on current_state gaps
- Examples: "All planned routes functional", "Test coverage >80%", "Deployed to production"

**Question 3: Obstacles**
- "What internal blocks might prevent success?"
- Suggest common obstacles: procrastination, perfectionism, scope creep, unclear requirements
- Allow custom input

**Question 4: Deadline**
- "When must this be complete?"
- Provide time-based options: 1 week, 2 weeks, 1 month, 3 months, Other

### 4. Generate Execution Plan
Using the same logic as `/add-goal`:

1. **Reverse-engineer milestones** bridging current_state → done_when
2. **Break down independent tasks** between milestones
3. **Estimate effort**: Points (1,2,3,5,8) and blocks per task
4. **Assign energy levels**: in/out per task
5. **Create if-then rules** from obstacles

### 5. Present Complete Plan
Show the human:
- WOOP summary
- All milestones in order
- All tasks with estimates
- If-then contingency rules
- Total estimated effort
- Projected completion timeline

Wait for approval (accept/modify/reject).

### 6. Save Goal
When approved:

1. Generate unique goal ID (read existing goals.json)
2. Save WOOP data to `$DIR/plans/goal-{id}-woop.json`
3. Save structured plan to `$DIR/plans/goal-{id}-original.json`
4. Add goal to `$DIR/goals.json`
5. Update `$DIR/state.json` activeGoals array

## Key Principles

**Thoroughness:** The analysis must be comprehensive. Use Task tool with Explore agent to deeply examine the codebase.

**Accuracy:** current_state must reflect reality, not aspirations. Be honest about gaps and incomplete work.

**Actionability:** The generated plan should immediately enable `/next` to assign meaningful tasks.

**Integration:** Once imported, this goal works identically to manually created goals - no special handling needed.

## Example Session

```
Human: /analyze-project /Users/db/projects/my-saas-app

You: [Launches Explore agent to analyze codebase comprehensively]

You: [After analysis completes]
I've analyzed the project at /Users/db/projects/my-saas-app.

Current State:
- Next.js 14 app with TypeScript and App Router
- Supabase configured for auth and database
- 4 of 10 planned dashboard pages implemented
- Stripe integration stubbed (test keys only)
- Email notifications configured but not tested
- No error handling or loading states
- Build works, no deployment setup

[Uses AskUserQuestion to gather wish, done_when, obstacles, deadline]

You: [Generates complete plan with milestones and tasks]

Here's the execution plan:

**Milestone 1: Complete Core Features**
- [5 tasks with estimates]

**Milestone 2: Production Readiness**
- [4 tasks with estimates]

Total: 23 points, ~18 blocks estimated

Accept this plan?