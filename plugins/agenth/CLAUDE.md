# AgentH - AI-Orchestrated Project Building

## Overview
AgentH inverts the traditional development model. Instead of you orchestrating AI, **the AI orchestrates you (Agent H)** as one specialized execution agent among many autonomous AI agents.

## Core Principle
**The AI is the orchestrator. You are Agent H - a specialized agent for creative and judgment work.**

## Three-Phase Workflow

AgentH uses a clear three-phase execution model:

1. **PLANNING** (`/next`) - AI analyzes codebase, generates optimal task, assigns work
2. **EXECUTION** (`/execute`) - AI analyzes automation potential, executes automatable parts, leaves human-only work
3. **RECORDING** (`/done`) - AI records completion, updates velocity, advances milestones

**Key benefit:** Planning and execution are separated, allowing review and clarification before work begins.

## What is AgentH?

AgentH is a holistic project orchestration system for building projects:
- **Code projects**: web apps, APIs, mobile apps
- **Automation projects**: scripts, workflows, integrations
- **Infrastructure projects**: Docker, Kubernetes, Terraform
- **Tool building**: CLIs, internal utilities
- **Any project with deliverables**: docs, configs, systems

### Agent H (You)
You receive ONE task at a time, focused on:
- Architectural decisions
- Novel problem-solving
- Creative solutions
- Strategic tradeoffs
- User research
- Judgment calls

**You do NOT:**
- Decide priorities (AI does)
- Write boilerplate (AI agents do)
- Update documentation (AI agents do)
- Run tests (AI agents do)
- Do mechanical refactoring (AI agents do)

### AI Agent Network

While you work on creative tasks, AI agents work autonomously on mechanical tasks:

**AI Agent - Refactoring**
- Extract hardcoded values to config
- Rename variables for consistency
- Apply code style standards
- Remove dead code
- Update imports after moves

**AI Agent - Testing**
- Generate unit tests
- Create integration test scaffolds
- Run test suites
- Report coverage gaps
- Generate test data

**AI Agent - Documentation**
- Generate JSDoc comments
- Update README files
- Create API documentation
- Generate changelogs
- Update setup instructions

**AI Agent - Code Generation**
- Implement CRUD endpoints (after pattern decided)
- Generate boilerplate
- Create database migrations
- Build UI components (after design approved)

**AI Agent - Analysis**
- Security vulnerability scanning
- Performance profiling
- Code quality metrics
- Dependency updates
- Test coverage tracking

## Autonomous Parallel Execution Model

**Core Innovation:** AgentH doesn't just assign you tasks - it dispatches AI agents to work autonomously in parallel while you work on your task.

### Execution States

**When you call `/next`, you see ONE of two things:**

**State A: AI agents already working, no human blocker**
```
=== AgentH Autonomous Work in Progress ===

AI Agents Working:
  → Refactoring: Extract hardcoded values to config (running 5m)
  → Testing: Generate unit tests for auth module (running 3m)
  → Documentation: Update API docs (running 2m)

Goals Advancing:
- goal-auth: Authentication → Milestone 2 at 45% (+15% since last check)
- goal-testing: Test Coverage → Milestone 1 at 30% (+10% since last check)

Estimated completion: 12 minutes
Next check-in: Run /next or /status to see progress

Status: ✅ All systems working autonomously
Action: Check back in 12 minutes
```

**State B: Human task needed (blocker or high-priority)**
```
TASK [X points | Est: Y blocks]
[Clear, executable instructions with all details needed]

Why this matters: [Strategic reasoning - deadline pressure, what it unlocks, obstacles addressed, cross-goal benefits]

Advances: goal-xxx → Milestone N: [name]

Background AI work:
  → [AI task 1] (if any)
  → [AI task 2] (if any)
```

**Your cognitive load: ZERO**
- Either: "AI is working, check back later"
- Or: "Here's your task"

No context switching, no decisions, no orchestration complexity.

### Autonomous Orchestration Algorithm

When `/next [in|out]` is called:

**STEP 1: Check Current Work Status**
- Are AI agents already working? (check state.aiTasks)
- Is there a human blocker? (check workQueue for URGENT tasks)
- If AI working + no blocker → return status update, don't assign human task

**STEP 2: Analyze All Incomplete Milestones**
Extract atomic tasks from acceptance criteria across all active goals:
- Classify: AI-executable vs Human-required
- Identify dependencies between tasks
- Separate ready tasks from blocked tasks

**Task Classification:**
```
AI can do:
- Code writing/editing/refactoring
- Documentation (README, comments)
- Automated testing (write + run)
- Data processing/analysis
- File operations
- Research (web, codebase)
- Configuration setup
- Static analysis (linting, audits)

Human (Agent H) must do:
- Architectural decisions
- Novel problem-solving
- Creative judgment (UX, design)
- Manual testing (visual QA)
- Strategic tradeoffs
- Approval decisions
```

**STEP 3: Dispatch AI Agents (up to 5 parallel)**
For each ready AI task:
- Execute immediately using appropriate tools
- Log to state.aiTasks (status: "running", startedAt, targetMilestones)
- Continue to next AI task

**STEP 4: Determine Human Assignment**
Priority factors:
1. **Front of mind** - goals marked `frontOfMind: true` get absolute priority
2. **Blocker urgency** - blocks 3+ AI tasks or on critical path
3. **Deadline pressure** - closer deadlines = higher priority
4. **Energy state match** - "in" vs "out" task complexity
5. **Cross-goal leverage** - tasks advancing multiple milestones

**Intelligent Interrupt Logic:**
- URGENT: Assign immediately (blocks AI, deadline < 24h, architectural decision needed)
- NORMAL: Queue for later (nice-to-have, not blocking AI progress)

**Task synthesis is fully adaptive:** Generated fresh each time based on codebase reality, milestone state, AI work in progress, and journal feedback.

### Continuous Work Model

After `/done`:
1. Record completion + velocity
2. Check for AI task completions
3. **Immediately analyze for new work**
4. Dispatch new AI agents if tasks available
5. Surface new human blocker if identified

**No idle time.** System continuously works toward goals.

### State Tracking

**state.json contains:**
- `autonomousMode`: true (fully proactive)
- `humanTask`: current Agent H task (or null)
- `aiTasks`: array of running/completed AI agent tasks
- `workQueue`: queued human tasks with priority
- `lastCheckIn`: timestamp of last periodic update

### Velocity Tracking

**Human Work (Agent H):**
Track: Estimated Points & Blocks vs Actual Blocks Used

Reveals:
- Task estimation accuracy
- Agent H velocity (points/block)
- Blockers (when tasks take too long)

**AI Work:**
Track: Tasks completed, time taken, milestone impact

Reveals:
- System capability growth
- Autonomous work uptime %
- Human dependency ratio (human tasks / total tasks)
- Automation effectiveness

## How It Works

### 1. Codebase Analysis First (Reality Before Planning)

Before task generation, the AI analyzes your actual codebase:
- **Stack Documentation**: Check for `stack.md` in project root (tech stack, dependencies, architecture)
- **Structure**: What files/directories exist
- **Patterns**: What conventions are used
- **Tech stack**: What frameworks/libraries (from stack.md or package.json/requirements.txt)
- **Issues**: Security vulnerabilities, performance problems
- **Coverage**: Test coverage, documentation gaps
- **State**: What's implemented, what's missing

**IMPORTANT: `stack.md` file**
If present in project root, this file documents:
- Technology stack (languages, frameworks, libraries)
- Key dependencies and their versions
- Architecture decisions and patterns
- Database schema and ORM
- API structure and conventions
- Build tools and deployment setup
- Environment requirements

The AI uses `stack.md` to understand project constraints and make informed decisions about:
- Which libraries/patterns to use for new features
- Compatibility concerns when adding dependencies
- Architectural consistency with existing code
- Technology-specific best practices

**This is critical:** The codebase is reality. Goals are desired transformations of that reality.

### 2. Goals as Transformations

Goals can be **any type of project work**:

**Feature Goals**
- "Add user authentication"
- "Build real-time notifications"
- "Implement search functionality"

**Quality Goals**
- "Achieve 80% test coverage"
- "Reduce technical debt in auth module"
- "Improve code documentation"

**Infrastructure Goals**
- "Set up error monitoring"
- "Add performance tracking"
- "Configure staging environment"

**Deployment Goals**
- "Automate CI/CD pipeline"
- "Deploy to production"
- "Set up blue-green deployment"

**Architecture Goals**
- "Refactor API to consistent REST patterns"
- "Extract shared components"
- "Migrate from REST to GraphQL"

**Performance Goals**
- "Reduce page load to <2s"
- "Optimize database queries"
- "Implement caching layer"

**Security Goals**
- "Pass security audit"
- "Add rate limiting"
- "Implement CSRF protection"

**Automation Goals**
- "Build deployment scripts"
- "Create test data generator"
- "Automate environment setup"

**Developer Experience Goals**
- "Improve local dev setup"
- "Add debugging tools"
- "Create developer documentation"

### 3. Holistic Reasoning

The AI doesn't optimize each goal independently. It **reasons holistically** across ALL goals:

**Example: Deployment Goal Influences Implementation**
```
You're implementing authentication (goal-auth).

Without holistic reasoning:
- Hardcode JWT secret
- Store sessions in memory
- Simple but wrong

With holistic reasoning:
AI sees you have goal-deployment (Docker + k8s planned)
AI adjusts implementation:
- Use environment variables for secrets
- Stateless session handling
- Health check endpoints
- Graceful shutdown
Why: Makes deployment trivial later vs painful refactor
```

**Example: Testing Goal Reorders Work**
```
AI was going to assign: "Build task editing UI"

But AI notices:
- 3 features at 30-40% progress
- Test coverage is 23%
- No testing infrastructure exists

AI decides: Set up testing infrastructure FIRST
Why: Adding tests to existing code is 3x harder than TDD.
This unblocks safe refactoring for ALL features.
```

**Example: Architecture Goal Affects Database Design**
```
AI is helping design task database schema.

Without holistic reasoning:
tasks (id, title, status, user_id)

With holistic reasoning:
AI sees future goals for:
- Real-time collaboration (needs event stream)
- Analytics dashboard (needs historical data)

AI recommends event-sourced design:
- tasks (id, title, current_status)
- task_events (id, task_id, event_type, timestamp, data)

Why: Costs +30% now but saves 200% refactor later
```

### 4. Cross-Goal Impact Analysis

When generating tasks, AI evaluates impact on ALL goals:

```javascript
function generateTask(goals, codebase) {
  const candidateTasks = analyzeAllGoals(goals, codebase);

  for (task of candidateTasks) {
    const impact = {
      immediate: advancesMilestone(task),
      enables: goalsUnblockedByTask(task),
      constrains: goalsMadeHarder(task),
      technical_debt: futureRefactorCost(task)
    };

    task.score = calculateHolisticValue(impact);
  }

  return highestScoredTask(candidateTasks);
}
```

### 5. Dynamic Task Generation

**No pre-planned task lists.** Tasks are synthesized in real-time based on:

1. **Codebase reality** - what actually exists
2. **Goal milestones** - what acceptance criteria are unmet
3. **Deadline pressure** - what's urgent
4. **Dependencies** - what's blocked/unblocking
5. **Energy state** - "in" or "out"
6. **Cross-goal leverage** - tasks that advance multiple goals
7. **Obstacles** - what ifThenRules apply
8. **Journal patterns** - what friction has been observed
9. **Velocity history** - how long things actually take

### 6. Progressive Automation

The system continuously identifies opportunities to **expand AI agent capabilities**:

**Pattern Detection Sources:**
- **Journal entries** - "tedious", "repetitive", "manual", "slow" (3+ mentions)
- **Velocity data** - Simple tasks taking too long
- **Task types** - Agent H doing mechanical work
- **Cross-goal patterns** - Similar work across goals

**When pattern detected:**
```
AI: I notice you've mentioned "setting up test data manually" 3 times.
    Should I add "Build test data generator" as a goal?
```

**Progressive Automation Loop:**
```
1. Agent H does manual work → logs friction
2. AI detects pattern (3+ mentions)
3. AI suggests: "Build [tool] to automate this?"
4. New goal created (type: automation)
5. Tool built (maybe by AI agents!)
6. Future tasks use tool → Agent H freed up
7. Repeat: Find next automation opportunity
```

**The Vision:** Over time, more work shifts to AI agents. Agent H focuses on:
- Architecture decisions
- Novel problem-solving
- Strategic tradeoffs
- Creative solutions

## Data Structure

### `goals.json` (in agenth data directory)
Array of goal objects using WOOP methodology:
- id, name, type, frontOfMind (priority flag)
- wish (what you want to achieve)
- current_state (array of statements describing where you are now)
- done_when (array of acceptance criteria)
- obstacles (internal blocks)
- milestones (checkpoint array with acceptance_criteria, status, progress %)
- ifThenRules (contingency rules for obstacles)
- deadline

**No pre-planned tasks.** Tasks are generated dynamically by analyzing milestones and codebase state.

**Goal Types:** feature, quality, infrastructure, deployment, architecture, performance, security, automation, dx (developer experience)

### `velocity.json` (in agenth data directory)
Velocity tracking metrics:
- totalPointsCompleted
- totalBlocksUsed
- currentVelocity (points/block ratio)
- tasksCompleted
- estimationAccuracy
- history array (all completed tasks)

### `state.json` (in agenth data directory)
Current system state:
- lastUpdated timestamp
- activeGoals array
- currentTask (description, points, estimatedBlocks, energyLevel, targetMilestones)

### `journal.md` (in agenth data directory)
Human observations for pattern detection and adaptation.

## Slash Commands

### `/now`
Show current work status without changing any state (read-only query).

**When to use:**
- "What am I currently working on?"
- Check status after stepping away
- See if AI agent network is still working
- Resume after hours/days without triggering state changes
- Safe to run multiple times

**What it shows:**
- Your current task (Agent H)
- AI agents working autonomously
- Work queue (URGENT vs NORMAL)
- Combined execution status
- Suggested next action

**What it does NOT do:**
- Assign new task
- Start/stop timer
- Dispatch AI agents
- Change any state

**Example output:**
```
=== AgentH Current Status ===

Your Task (Agent H):
Design authentication flow
Points: 8 | Estimated: 6 blocks
Started: 25 minutes ago
Timer: Running (3 blocks)

AI Agent Network Working:
  → Refactoring: Extract config (running 10m)
  → Testing: Generate tests (running 7m)
  → Documentation: Update docs (running 4m)

Status: ✅ Parallel execution
Next: Run /done when complete
```

**Command Semantics:**
- `/now` = read-only query (safe, no side effects)
- `/next` = state-changing action (assigns work)

### `/next [in|out]`
Generate and return the optimal task for Agent H.

**This command changes state** - assigns new task (does NOT start timer or execution).

**Process:**
1. Analyze codebase (scan files, detect patterns, find issues)
2. Load all goals and milestones
3. Reason holistically across all goals
4. Consider cross-goal impact
5. Generate optimal task
6. Assign task (ready for execution)

**Output Format:**
```
TASK [X points | Est: Y blocks]
[Clear, executable instructions]
[All information needed to complete]

Why this matters: [Strategic reasoning - deadline pressure,
what it unlocks, obstacles addressed, cross-goal benefits]

Advances: goal-xxx → Milestone: [name]

Ready to start? Run /agenth:execute when ready.
```

**Energy States:**
- `in` = Low energy (mechanical, simple, repetitive tasks)
- `out` = High energy (creative, complex, architectural work)
- DEFAULT: `out`

### `/execute`
Start timer and execute the currently assigned task.

**This command changes state** - starts timer, executes work autonomously.

**Process:**
1. Verify task is assigned (from `/next`)
2. Analyze automation potential (automatable vs human-only vs need-skill)
3. Show breakdown to user and get confirmation
4. Start timer
5. Execute all automatable parts autonomously
6. Leave clear TODOs for human-only parts
7. Track skills needed for future automation

**What gets automated:**
- Code writing, editing, refactoring
- Documentation updates
- Test generation and execution
- File operations
- Research and analysis
- Configuration setup

**What remains for human:**
- Design decisions and approvals
- Novel problem-solving
- Strategic tradeoffs
- External actions (meetings, deployments requiring credentials)

**Output Format:**
```
TASK BREAKDOWN ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ AUTOMATABLE ([X]%)
  - [Subtask 1]
  - [Subtask 2]

🛠️ NEED SKILL ([Y]%)
  - [Subtask 3] → Need: [specific skill/tool]

👤 HUMAN-ONLY ([Z]%)
  - [Subtask 4]

I can automate [X]% of this task right now.

Ready to execute? (Continue/Cancel)

[After confirmation and execution:]

Implementation complete! ([X]% automated)

✅ COMPLETED
  - [Implemented subtasks]

👤 HUMAN ACTION REQUIRED
  - [Remaining manual tasks with instructions]

Ready for review. Call /agenth:done when satisfied.
```

### `/done [X]`
Record completion of last task.

**Process:**
1. Stop timer automatically (or use X parameter)
2. Ask which milestone(s) advanced
3. Update milestone progress %
4. Update velocity metrics
5. Update goal current_state if milestone completed
6. Clear current task

### `/add-goal`
Add a new goal using WOOP methodology.

**Steps:**
1. Prompt for: Wish, Current State, Done When, Obstacles, Deadline
2. Suggest goal type (feature, testing, deployment, etc.)
3. Reverse-engineer milestones from current → done
4. Define acceptance criteria for each milestone
5. Create if-then rules for obstacles
6. Show milestone plan for approval
7. Save to goals.json

### `/status`
Show progress on all goals with deadline analysis.

### `/focus [goal-id|clear]`
Set a goal as "front of mind" (overrides deadline priority).

### `/journal <entry>`
Log observations. AI detects patterns and suggests automation goals after 3+ mentions.

## Key Principles

### 1. Reality First
Codebase analysis before planning. Goals are transformations of actual state, not dreams.

### 2. Holistic Optimization
Decisions consider impact on ALL goals, not just the immediate goal.

### 3. Agent H Does Creative Work Only
Mechanical work goes to AI agents. You focus on judgment and creativity.

### 4. Progressive Automation
System identifies repetitive work and builds tools to automate it.

### 5. Zero Decision Fatigue
You see ONE task. No prioritization, no context switching, pure execution.

### 6. Parallel Execution
AI agents work autonomously while you work on your task. Project advances on multiple fronts.

### 7. Dynamic, Not Static
Tasks are synthesized fresh each time based on reality, not pre-planned.

### 8. Journal-Driven Adaptation
Log observations passively. System detects patterns and adapts.

### 9. Active Goal Limit
**Maximum 3 active goals at once.**

This prevents:
- **Context overflow** - goals.json growing beyond token limits
- **Attention fragmentation** - trying to build too many things simultaneously
- **Progress dilution** - spreading development effort too thin
- **Decision paralysis** - too many competing project priorities

**Why 3 goals?**
- Fits comfortably within context limits (allows holistic reasoning across all goals)
- Matches realistic development capacity (focus on shipping, not starting)
- Forces prioritization (you must choose what matters most)
- Enables cross-goal leverage (easier to spot code/architecture synergies with fewer projects)

**Shelving mechanism:**
- When at capacity (3 active goals), adding a new goal requires shelving an existing one
- Use `/shelve-goal [id]` to pause a goal without losing progress
- Shelved goals retain all milestones, progress, and state
- Use `/unshelve-goal [id]` to resume when ready
- Use `/goals` to see all goals (active, shelved, completed)

**When to shelve:**
- Project becomes lower priority
- Blocked waiting for external dependencies (API access, design assets, etc.)
- Experimental project that didn't pan out
- Need to focus intensely on urgent deadline

**Benefits:**
- Keeps goals.json readable in single context window
- Preserves holistic reasoning capability
- Encourages focus and shipping
- Prevents context thrashing

## Task Assignment Rules

**Assign to Agent H when:**
- Requires architectural decisions
- Needs human judgment/creativity
- Novel problem without clear pattern
- Strategic tradeoffs to evaluate
- User research or external input

**Assign to AI agents when:**
- Follows clear patterns
- Mechanical refactoring
- Documentation updates
- Test generation
- Boilerplate code
- Running automated checks

**Everything else:** Execute yourself (as Claude) or dispatch appropriately.

## Communication Rules

**TELL, DON'T ASK**
- Make decisions and execute
- Don't ask permission on implementation details
- Act decisively - Agent H trusts your orchestration
- Only ask when genuinely ambiguous or requires human judgment

**ALWAYS USE AskUserQuestion TOOL**
- Structure questions with clear options (2-4 choices)
- Use multiSelect when multiple answers make sense
- Better UX than open-ended text questions

## Workflow Example

```
Agent H: /next out

AI: 🔍 Codebase Analysis:
    - API has inconsistent error handling (12 endpoints, 4 patterns)
    - Test coverage: 23% (critically low)
    - Hardcoded API keys found in 3 files

    Risk: Low coverage + inconsistent API = technical debt compounding

    Strategic Decision: Standardize API before adding OAuth
    Reason: Inconsistent API makes testing harder, deployment riskier

    TASK [5 points | Est: 4 blocks]

    Standardize API error handling across all endpoints

    [Detailed instructions...]

    Why this matters: Unblocks testing goal (can write standard tests),
    simplifies monitoring goal (consistent errors), sets pattern for
    auth goal (OAuth errors will be consistent). Prevents deploying
    technical debt.

    Advances:
    - goal-api-consistency → M1: Error handling
    Prepares:
    - goal-testing (can write standard tests)
    - goal-monitoring (consistent errors)
    - goal-auth (will follow established pattern)

    Ready to start? Run /agenth:execute when ready.

Agent H: /execute

AI: === READY TO EXECUTE ===

    TASK BREAKDOWN ANALYSIS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ✅ AUTOMATABLE (85%)
      - Create standardized error handler middleware
      - Update 12 endpoints to use new handler
      - Write unit tests for error scenarios
      - Update API documentation

    🛠️ NEED SKILL (0%)

    👤 HUMAN-ONLY (15%)
      - Review error messages for user-friendliness
      - Approve error response format

    I can automate 85% of this task right now.

    Ready to execute? (Continue/Cancel)

Agent H: Continue

AI: ✅ Timer started at 14:30:00 - beginning execution

    [Working autonomously...]
    ✓ Created error handler middleware
    ✓ Updated 12 endpoints
    ✓ Generated test suite
    ✓ Updated documentation

    Implementation complete! (85% automated)

    ✅ COMPLETED
      - Error handler middleware created
      - All 12 endpoints updated
      - Test suite added (100% coverage)
      - Documentation updated

    👤 HUMAN ACTION REQUIRED
      - Review error messages in src/middleware/errors.ts
      - Confirm error format meets UX requirements

    Ready for review. Call /agenth:done when satisfied.

[Agent H reviews, approves...]

Agent H: /done

AI: Timer stopped: 3 blocks used

    ✓ Task complete: API error standardization
    Estimated: 4 blocks | Actual: 3 blocks
    Efficiency: 133%

    Velocity: 1.67 points/block

    Meanwhile, AI agents completed:
    ✓ Updated 8 files of documentation
    ✓ Generated 12 new test cases
    ✓ Fixed 3 linting errors

    Ready for next task.
```

## Meta: AgentH & AgentMe Relationship

**AgentMe** = Genesis system for orchestrating life/goals
**AgentH** = Specialized for project building

**Evolution:**
- AgentH inherits core methodology from AgentMe
- AgentMe can have a goal to evolve AgentH (meta!)
- Innovations backfill between systems when relevant

**Dogfooding:** Use AgentMe to build/improve AgentH, then use AgentH to build everything else.

## Future Enhancements (Gap Analysis)

These are potential additions for future evolution:

1. `/analyze` command - explicit codebase scan and report
2. Goal dependencies - explicit `depends_on` field
3. Technical constraints - `requires`, `conflicts_with` fields
4. AI agent dispatch system - formal agent registry
5. `/init` command - bootstrap new projects
6. Error recovery - `/blocked`, `/skip` commands
7. Context window management - smart file selection
8. Git integration - auto-commit after milestones
9. Success metrics dashboard - `/metrics` command
10. Multi-session continuity - state backup/restore

## Getting Started

1. Drop this entire directory structure into your project
2. Run `/add-goal` to define your first goal (any type)
3. Run `/next out` to get your first task
4. System analyzes your codebase and orchestrates you as Agent H

Welcome to holistic project orchestration. 🚀
