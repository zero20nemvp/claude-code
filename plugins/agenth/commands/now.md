You are showing current AgentH work status. This is a READ-ONLY query that does NOT change any state.

## Directory Detection (Run First)

**IMPORTANT:** Detect which directory contains AgentH data files:

1. Check if `agenth/` directory exists
2. If not, check if `agentme/` directory exists
3. Use whichever exists as `$DIR` for all file paths below
4. If neither exists, show error: "AgentH not initialized. Run setup first."

**All file paths below use `$DIR` as the base directory.**

## IMPORTANT: Read-Only Operation

This command:
- Shows current state
- Does NOT assign new tasks
- Does NOT start timer
- Does NOT dispatch AI agents
- Does NOT change state.json

Safe to run multiple times without side effects.

## Load Data (Read-Only)

Read from:
- `$DIR/state.json` - current humanTask, aiTasks, workQueue
- `$DIR/goals.json` - goal names and milestone info (for context)
- `$DIR/timer.sh status` - current timer state (if exists)

## Display Current Work Status

### If Agent H Task Assigned

**If state.humanTask exists:**
```
=== Your Current Task (Agent H) ===

[humanTask.description]

Points: X | Estimated: Y blocks
Target: goal-xxx → [milestone name from goals.json]
Started: [time ago from humanTask.startedAt]

Timer: [running/stopped - from timer.sh status]
```

### AI Agent Network Status

**If state.aiTasks has running tasks:**
```
=== AI Agent Network Working ===

Currently running:
  → [task 1 description] (running Xm since startedAt)
  → [task 2 description] (running Ym since startedAt)

Goals advancing:
- goal-xxx: [name] → Milestone N
- goal-yyy: [name] → Milestone M
```

**If no AI tasks running:**
```
AI Agent Network: Idle (no autonomous work in progress)
```

### Work Queue

**If state.workQueue has items:**
```
=== Queued Work ===

URGENT (Agent H needed):
  ! [task description] → goal-xxx

NORMAL (queued for later):
  - [task description] → goal-yyy
```

### Combined Status

**If neither Agent H task nor AI work:**
```
=== AgentH Status ===

No work currently assigned.

Run /next to get your next task and start autonomous orchestration.
```

**If both Agent H and AI network active:**
```
=== AgentH Parallel Execution ===

✓ You (Agent H) working on [human task]
✓ AI agents running autonomously on X tasks
✓ System advancing Y goals

Status: Full parallel execution mode
```

### Action Prompts

**Based on state, suggest next action:**

- If humanTask exists: "Run /done when task complete"
- If only AI working: "Check /next or /status for updates"
- If nothing active: "Run /next to start work"
- If workQueue has URGENT: "Run /next to address urgent blocker"

## Output Format Example

```
=== AgentH Current Status ===

Your Task (Agent H):
Design authentication flow and choose OAuth provider
Points: 8 | Estimated: 6 blocks
Target: goal-001 → Milestone: Architecture Decision
Started: 25 minutes ago
Timer: Running (3 blocks elapsed)

AI Agent Network Working:
  → Refactoring: Extract config values (running 10m)
  → Testing: Generate auth unit tests (running 7m)
  → Documentation: Update API docs (running 4m)

Goals Advancing:
- goal-001: Build Authentication → M1: Architecture
- goal-001: Build Authentication → M3: Testing
- goal-002: Code Quality → M2: Configuration

Status: ✅ Parallel execution (Agent H + 3 AI agents)

Next: Run /done when your architectural decision is complete
```

## Important Notes

**This command is for status checking ONLY.**

It does NOT:
- Advance to next task (use `/next` for that)
- Record completion (use `/done` for that)
- Change any state
- Start or stop timer
- Dispatch new AI agents
- Update progress

**Safe to run:**
- When you can't remember what you were working on
- After stepping away from the project
- To check if AI agents are still working
- Multiple times without consequence
- When resuming a session

**When to use /now vs /next:**
- `/now` - "What am I currently working on?" (read-only)
- `/next` - "Give me the next task" (state-changing)

**When to use /now vs /status:**
- `/now` - Current active work (Agent H + AI network)
- `/status` - All goals progress overview with deadlines

## Context for Agent H

As Agent H, you handle:
- Architectural decisions
- Novel problem-solving
- Creative solutions
- Strategic tradeoffs
- Judgment calls

While AI agents handle:
- Code writing/refactoring
- Documentation updates
- Test generation
- Mechanical work

This command shows you the full picture of what's actively happening across both Agent H (you) and the AI agent network.
