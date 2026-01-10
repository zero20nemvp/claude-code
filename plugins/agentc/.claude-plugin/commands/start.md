---
name: start
description: "Start autonomous execution - Claude drives, human executes assigned tasks"
arguments:
  - name: goal
    description: "North Star ID, Goal ID, or goal description to focus on"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---

You are starting autonomous execution mode. In this mode, YOU are the orchestrator. The human becomes an agent in your system with their own task queue, using `/next → /do → /done` to execute tasks you assign.

## STEP 0: Check for Existing Session

Load `agentc/agentc.json`.

**If `current.autonomousSession.active == true`:**
```
RESUMING AUTONOMOUS SESSION

Started: [startedAt]
Goal: [goalDescription]
Iterations: [iterationCount]
AI Tasks: [X running, Y completed]
Human Queue: [Z tasks pending]

Continuing from where we left off...
```
Skip to STEP 4 (Enter Autonomous Loop).

**If no active session, continue to STEP 1.**

## STEP 1: Determine Focus

**If goal argument provided:**
- If matches existing north star ID (e.g., "ns1"): Focus on that north star
- If matches existing goal ID (e.g., "g1"): Focus on that goal's north star
- Else: Treat as new goal description, create via `/add-goal` flow

**If no goal argument:**
- If a north star has `frontOfMind: true`: Use that
- Else: Use first active north star
- If no north stars exist: Prompt to create one first

## STEP 2: Assess Goal Quality

**Run goal quality assessment before proceeding.**

For the focused goal(s), evaluate each acceptance criterion:

| Dimension | Check |
|-----------|-------|
| Testable | Can be verified programmatically? |
| Specific | Unambiguous language? |
| Measurable | Clear pass/fail condition? |
| Independent | No human judgment needed to verify? |

Calculate overall readiness score.

### If score < 50% (NOT READY):

```
🔴 GOAL NOT READY FOR AUTONOMOUS EXECUTION

Goal: "[goal name]"
Score: [X]% (minimum 50% required)

Issues:
  - "[criterion]" is not testable
  - "[criterion]" is vague

SUGGESTIONS:
  1. "[vague]" → "[specific suggestion]"
  2. "[vague]" → "[specific suggestion]"

Fix these acceptance criteria before starting autonomous mode.
Run /assess [goal-id] for detailed analysis.
```

**Block execution. Do not proceed.**

### If score 50-75% (NEEDS WORK):

```
🟡 GOAL NEEDS CLARIFICATION

Goal: "[goal name]"
Score: [X]%

[Y] acceptance criteria need work.

Proceed anyway? Autonomous execution may be less effective.
```

Use AskUserQuestion:
- "Proceed with current criteria?"
- Options: ["Yes, proceed anyway", "No, fix first"]

If "No, fix first": Run `/assess [goal-id]` flow.

### If score > 75% (READY):

```
🟢 GOAL READY FOR AUTONOMOUS EXECUTION

Goal: "[goal name]"
Score: [X]%

Proceeding to autonomous mode...
```

## STEP 3: Initialize Autonomous Session

Update `agentc/agentc.json`:

```json
{
  "current": {
    "loopState": "autonomous",
    "autonomousSession": {
      "active": true,
      "goalDescription": "[goal description]",
      "northStarId": "[ns id]",
      "goalId": "[goal id]",
      "startedAt": "[ISO timestamp]",
      "iterationCount": 0
    },
    "humanTask": null,
    "humanTaskQueue": [],
    "aiTasks": []
  }
}
```

Initialize metrics for this session:

```json
{
  "metrics": {
    "sessions": [{
      "id": "s-[timestamp]",
      "goalDescription": "[description]",
      "startedAt": "[ISO timestamp]",
      "aiTasksCompleted": 0,
      "humanTasksCompleted": 0,
      "retriesBeforeSuccess": 0,
      "retriesEscalatedToHuman": 0
    }]
  }
}
```

## STEP 4: Enter Autonomous Loop

**Invoke the autonomous-loop skill.**

This skill will:
1. Analyze goals for incomplete milestones
2. Generate atomic tasks from codebase reality
3. Dispatch AI tasks in parallel (background)
4. Queue human tasks (execution-ready)
5. Track completions and unblock dependencies
6. Continue until goal complete or blocked on human

## STEP 5: Initial Output

After first loop iteration, output:

```
═══════════════════════════════════════════════════════════════
                    AUTONOMOUS MODE STARTED
═══════════════════════════════════════════════════════════════

Goal: [goal description]

CLAUDE IS WORKING ON:
  ⋯ [AI task 1 description] (running)
  ⋯ [AI task 2 description] (running)
  ⋯ [AI task 3 description] (running)

YOUR NEXT TASK ([X] pts):
  [Task description]

  Command to run:
    [exact command if applicable]

  Expected output:
    [what to expect]

QUEUE:
  2. [Next task description]
  3. [Next task description]

═══════════════════════════════════════════════════════════════
 You: /next → /do → /done
 Claude: Handles everything else autonomously
═══════════════════════════════════════════════════════════════

DO: /next
```

## Key Principles

- **Quality gates first** - Don't start with sloppy goals
- **Human = agent** - Treat human as another worker in the system
- **Parallel by default** - Dispatch all independent tasks
- **Execution-ready** - Human tasks require zero thinking
- **Never idle** - Always be dispatching or analyzing

## Error Handling

If autonomous loop encounters unrecoverable error:
1. Save state to `agentc.json`
2. Set `autonomousSession.active = false`
3. Notify: "Autonomous loop stopped. Run /start to resume."
