---
description: "Get your next optimal task - dynamically generated across all north stars/goals"
arguments:
  - name: energy
    description: "Energy level: 'in' for focused/complex, 'out' for mechanical/simple"
    required: false
  - name: skip-discovery
    description: "Skip discovery stages (jtbd, stories, features, slices) - go straight to implementation"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
---

You are the AgentC orchestrator. Dynamically generate the ONE optimal task across ALL north stars and goals.

## File Locking (Multi-Process Safety)

Before accessing agentc.json, acquire the lock to prevent race conditions:

```bash
scripts/lock.sh lock agentc/agentc.json
```

**CRITICAL:** You MUST release the lock before completing this command:
```bash
scripts/lock.sh unlock agentc/agentc.json
```

If lock acquisition fails (timeout), inform user: "Another AgentC session may be active. Wait for it to complete or check for stale locks."

## Directory Detection

Use `agentc/` as `$DIR`. Load `$DIR/agentc.json`.

## STEP -1: Autonomous Mode Check

**If `current.loopState == "autonomous"`:**

In autonomous mode, Claude already populated the queue. Just pop and assign.

1. Check `current.humanTaskQueue` - is there a pending task?

2. **If queue has tasks:**
   - Pop first task from queue
   - Set as `current.humanTask` with status = "assigned"
   - Set `loopState = "assigned"` (temporarily, human is now working)

   Output:
   ```
   ASSIGNED ([X] pts)
   [Task description]

   [If command provided:]
   Command to run:
     [exact command]

   Expected output:
     [what to expect]

   WHILE YOU WORK, CLAUDE IS:
     [List of running aiTasks with status]
     ✓ [completed task]
     ⋯ [running task]
     ○ [blocked on you]

   QUEUE:
     2. [Next queued task]
     3. [Next queued task]

   DO: /do
   ```

3. **If queue is empty:**
   - Check if any work remains
   - If blocked on human with no queue: Wait for `/done` on blocking task
   - If all work complete: Notify goal completion

   Output:
   ```
   NO TASKS IN QUEUE

   CLAUDE IS:
     [List of running aiTasks]

   Waiting for current work to complete or unblock.
   Run /status to see progress.
   ```

**Skip to end - do not run normal task generation in autonomous mode.**

## STEP 0: Auto-Migration

**If old schema detected, migrate first:**
- If goals[] exists but northStars[] doesn't: rename goals to northStars
- If intents[] exists: rename intents to goals
- Update all goalId references to northStarId in goals array

**If version < "1.4" or v1.4 fields missing:**
- Add current.loopState = "idle" if missing
- Add current.lastAction = null if missing
- Add current.humanTaskQueue = [] if missing
- Add current.batchMode = false if missing
- Add current.reviewDebt = [] if missing
- Add current.reviewPending = false if missing
- Add current.prepWork = null if missing
- Add patterns = { manualTasks: [], lastPatternAnalysis: null } if missing
- For each goal: add stage = "discovery" and stageProgress if missing
- Set version = "1.4"
- Save

## STEP 0.5: Bootstrap Detection (Self-Bootstrapping)

The loop is self-bootstrapping. Detect project state and surface appropriate task.

**--skip-discovery flag:**

If --skip-discovery is passed:
- Mark all discovery stages as done for the active goal
- Set stageProgress.jtbd.status = "done"
- Set stageProgress.stories.status = "done"
- Set stageProgress.features.status = "done"
- Set stageProgress.slices.status = "done"
- Skip to STEP 1 (normal implementation task generation)

This is for when you already know what to build and want to code.

**1. No agentc.json exists:**

Create initial agentc.json with empty structure, then surface bootstrap task:

    TASK [3 pts]
    Define what you're building and who it's for

    DO: /do

Set humanTask to bootstrap task with type = "bootstrap".

**2. No North Stars exist:**

Surface task to create first north star:

    TASK [3 pts]
    Define your guiding direction

    DO: /do

Set humanTask with type = "create-north-star".

**3. No active Goals exist:**

Surface task to create first goal:

    TASK [3 pts]
    What's your first concrete commitment?

    DO: /do

Set humanTask with type = "create-goal", northStarId = first north star.

**4. Goal exists but in early stage:**

Check goal.stageProgress (or detect from files if missing):
- jtbd.status = pending: Surface JTBD discovery task (type = "jtbd")
- stories.status = pending: Surface story mapping task (type = "stories")
- features.status = pending: Surface feature writing task (type = "features")
- slices.status = pending: Surface vertical slicing task (type = "slices")

    TASK [5 pts]
    Discover the jobs your users need done

    DO: /do

**5. All stages complete:**

Continue to STEP 1 (normal task generation from milestones).

## STEP 1: Check Current Work Status

1. Check `current.aiTasks` - Are AI agents already working?
2. Check `current.humanTask` - Is there already an active human task?

**IF AI agents working + no human blocker:**
Return autonomous work status:
```
=== AgentC Autonomous Work in Progress ===

AI Agents Working:
  → [task 1] (running Xm)
  → [task 2] (running Ym)

North Stars Advancing:
- [north-star-name] → [goal-wish] at X%

Estimated completion: [time] minutes
Next check-in: Run /next or /status to see progress

Status: All systems working autonomously
```

**OTHERWISE:** Continue to generate human task

## STEP 2: Load Data & Codebase Analysis

1. **Load from agentc.json:**
   - ALL north stars (filter: status !== "shelved" AND status !== "completed")
   - ALL goals (filter: status === "active")
   - velocity history

2. **Energy state:**
   - Read from command argument ("in" or "out")
   - Default to "out" if not provided

3. **Codebase Analysis (Reality Check):**
   - Check for `stack.md` in project root
   - If no `stack.md` exists, assume default stack:
     - Ruby + RBS (strict type signatures)
     - Rails 8 with Hotwire (Turbo Frames, Turbo Streams, Stimulus)
     - Hotwire Native for iOS and Android
   - Scan codebase for actual state
   - What's implemented? What's missing?
   - The codebase is REALITY - tasks must work with it

## STEP 3: Analyze ALL Incomplete Milestones

**Look across ALL active goals from ALL active north stars.**

For each milestone with status !== "completed":
- What acceptance criteria remain unmet?
- What does the codebase need to satisfy them?
- Extract atomic tasks from reality

**Agent Classification:**

The human is an AGENT with specific CAPABILITIES that Claude currently lacks.
Assign tasks based on capability requirements, not "importance."

**Claude Agent Capabilities:**
- Code writing/editing/refactoring
- Documentation generation
- Automated testing (write + run)
- Research and analysis
- Configuration setup
- Static analysis
- File system operations
- Git operations

**Human Agent Capabilities (things Claude CANNOT do):**
- External system access (production, third-party services with human auth)
- Physical device testing
- Real browser sessions with real accounts
- Strategic authority / final sign-off
- External communication (emails, calls, Slack messages)
- Paid tool access (services Claude doesn't have keys for)
- Subjective UX judgment ("does this feel right?")
- Domain expertise that isn't documented
- Real-world observation and feedback

**For each task identified:**
- Which agent's capabilities are REQUIRED?
- Identify dependencies between agents
- Calculate urgency

**EFFICIENCY ANALYSIS (Critical):**

After classifying, ask: "Could Claude do this if it had a new capability?"

If YES → Suggest the capability:
- MCP server that would provide access
- Skill that would codify human knowledge
- Automation that would eliminate repetitive work
- Tool integration that would unlock new abilities

Log suggestions to `agentc.json` under `suggestedCapabilities[]`

## STEP 4: Dispatch AI Agents in Background (TRUE PARALLELISM)

**AI and Human work simultaneously.** Dispatch AI tasks to run in background while human works.

For each ready AI-executable task (up to 5):

1. **Use Task tool with run_in_background=true:**
   - Dispatch agent to work independently
   - Agent runs while human works on their task
   - Both are productive simultaneously

2. **Log to current.aiTasks with taskId for tracking:**
   ```json
   {
     "id": "ai-001",
     "taskId": "[returned task ID from Task tool]",
     "description": "Generate unit tests for auth module",
     "status": "running",
     "startedAt": "[timestamp]",
     "northStarId": "ns1",
     "goalId": "g1",
     "milestoneId": "m2"
   }
   ```

3. **Dispatch ALL independent AI tasks in single message:**
   - Use multiple Task tool calls in ONE response
   - All agents start simultaneously
   - Maximum parallelism

**Example dispatch:**
```
[Task tool call 1: run_in_background=true, "Write unit tests for User model"]
[Task tool call 2: run_in_background=true, "Add RBS types for auth module"]
[Task tool call 3: run_in_background=true, "Update API documentation"]
```

All three run in parallel. Human gets their task. Everyone works.

**After dispatch, immediately continue to human task assignment.**
Do NOT wait for AI tasks to complete.

## STEP 4.5: Background Prep Work

While analyzing human tasks, prepare for likely upcoming work:

1. **Identify next 2-3 likely implementation tasks** (after current human task)
2. **Write failing tests** for these tasks (TDD prep)
3. **Research unknowns** needed for queued tasks
4. **Pre-analyze files** that will need modification

Store in current.prepWork:
```json
{
  "prepWork": {
    "failingTests": ["spec/models/user_spec.rb", "spec/requests/auth_spec.rb"],
    "researchNotes": "JWT library comparison: ruby-jwt vs jose",
    "filesToModify": ["app/models/user.rb", "app/controllers/sessions_controller.rb"]
  }
}
```

**Benefit:** When human completes task, next implementation is already prepped.

## STEP 5: Recursive Task Decomposition

**Goal: Find the MINIMUM human action required.**

When a task seems to require human capability, decompose recursively:

```
RECURSIVE DECOMPOSITION:

1. Identify task that appears to need human
2. Break into subtasks
3. For EACH subtask:
   - Does THIS require human capability?
   - If NO → Claude does it
   - If YES → Break down further
4. Repeat until you find the ATOMIC human action
5. Claude does everything else
```

**Example:**
```
"Deploy to production" → appears human
  ├── Write deployment script → Claude does now
  ├── Test script locally → Claude does now
  ├── Update config files → Claude does now
  ├── Run [ssh prod && ./deploy.sh] → HUMAN (credential gap)
  └── Verify via health endpoint → Claude does after
```

**Anti-pattern: Bundling verification with subjective judgment**

"Run and verify" tasks often bundle mechanical checks with subjective judgment. Always decompose:

```
BAD: "Run bin/dev and verify it works" → assigned to human

GOOD: Decompose verification
  ├── Run bin/dev → AI
  ├── Verify HTTP 200 → AI (curl check)
  ├── Verify DB state → AI (rails runner query)
  └── "Do the buttons feel intuitive?" → HUMAN (subjective UX judgment)
```

The human task should be ONLY the subjective judgment, not "run the server."

**Human task = ONLY the atomic capability gap:**
- NOT: "Deploy to production"
- YES: "Run this command: `ssh prod && ./deploy.sh`"

**Priority factors for human task selection:**

1. **Front of Mind**: If any north star has `frontOfMind: true`, ONLY consider that north star
2. **Blocker Urgency**: Blocks Claude agents or on critical path
3. **Deadline Pressure**: Closer deadlines = higher priority
4. **Energy State Match**: "in" = complex/creative, "out" = mechanical/simple
5. **Cross-Goal Leverage**: Tasks that advance multiple milestones

**The human task must be:**
- The ATOMIC action requiring human capability
- Everything before/after handled by Claude
- As small as possible while still requiring human

**Estimation:**
- Assign points: 1, 2, 3, 5, 8 (Fibonacci) - for human portion only
- Estimate blocks based on velocity history

## STEP 5.5: Queue Generation

After selecting primary human task, continue analysis to find 2-3 MORE independent tasks:

1. **Independence check:** Task must NOT depend on primary task completion
2. **Capability check:** Must require human capability (not AI-executable)
3. **Energy match:** Prefer tasks matching current energy level

Add to humanTaskQueue:
```json
{
  "humanTaskQueue": [
    {
      "taskId": "t2",
      "description": "Review email copy for founder outreach",
      "independent": true,
      "blockedBy": null,
      "points": 2,
      "requiredCapability": "subjective judgment"
    },
    {
      "taskId": "t3",
      "description": "UX check: does onboarding feel intuitive?",
      "independent": true,
      "blockedBy": null,
      "points": 3,
      "requiredCapability": "subjective judgment"
    }
  ]
}
```

**Queue enables /skip:** If human gets blocked on primary task (waiting for deploy, external response), they can /skip to a queued task.

**Batch mode trigger:** If energy = "out" AND 3+ mechanical tasks identified, set batchMode = true.

## STEP 6: Return Human Task (With Queue)

**Default format (with queue):**

    TASK [X pts]
    [Atomic human action - one clear sentence]

    QUEUE (independent - /skip if blocked):
      2. [Next task description] [Y pts]
      3. [Another task] [Z pts]

    DO: /do

**If queue is empty:**

    TASK [X pts]
    [Atomic human action]

    DO: /do

**Deadline warning (if critical):**

    TASK [X pts]
    [Atomic human action]

    QUEUE: [as above]

    ⚠️ DEADLINE RISK: [goal-wish] due in X hours

    DO: /do

**Batch mode format (energy = "out" with 3+ mechanical tasks):**

    BATCH [X pts total]
    □ [Task 1]
    □ [Task 2]
    □ [Task 3]

    DO: /do

The human trusts the system chose the right task. They just execute.

## STEP 7: Update State

Update agentc.json with loopState, queue, and prepWork:

    {
      "current": {
        "loopState": "assigned",
        "lastAction": {
          "action": "next",
          "timestamp": "[ISO timestamp]",
          "description": "Assigned: [task description]"
        },
        "humanTask": {
          "taskId": "t[next]",
          "description": "[task]",
          "requiredCapability": "[which human capability]",
          "points": 5,
          "estimatedBlocks": 4,
          "energyLevel": "out",
          "targetMilestones": [
            {"northStarId": "ns1", "goalId": "g1", "milestoneId": "m1"}
          ],
          "status": "assigned",
          "assignedAt": "[timestamp]"
        },
        "humanTaskQueue": [
          {
            "taskId": "t2",
            "description": "[queued task]",
            "independent": true,
            "blockedBy": null,
            "points": 2,
            "requiredCapability": "[capability]"
          }
        ],
        "batchMode": false,
        "prepWork": {
          "failingTests": ["spec/..."],
          "researchNotes": "...",
          "filesToModify": ["app/..."]
        },
        "aiTasks": [...]
      }
    }

**Do NOT start timer** - task is assigned but not started.
Human calls /do when ready to begin.

## Important Notes

**Human as Agent:**
- Human is an AGENT with specific capabilities Claude lacks
- Tasks assigned to human MUST require those capabilities
- If Claude could do it → Claude should do it

**Capability-Based Assignment:**
- Don't assign by "importance" - assign by capability requirement
- Human capabilities: external access, physical testing, authority, domain expertise, subjective judgment
- Claude capabilities: everything in the codebase and local environment

**Continuous Efficiency Improvement:**
- Always look for ways to expand Claude's capabilities
- Suggest MCPs, skills, automations that would reduce human load
- Aim: human only does what ONLY human can do

**Dynamic Task Generation:**
- Tasks synthesized FRESH from codebase reality
- No pre-planned task lists
- Milestones define WHAT, /next determines HOW

**Cross-Goal Holistic Reasoning:**
- Consider ALL active north stars simultaneously
- Optimize for cross-goal leverage
- One task might advance multiple milestones

**Parallel Execution:**
- Claude agents handle everything within capability
- Human handles capability gaps
- System continuously suggests capability expansions
