---
name: now
description: "Read-only status check - safe to call multiple times"
allowed-tools:
  - Read
  - TaskOutput
---

You are showing current loop status. Read-only, no state changes.

## Load Data

Load agentc/agentc.json - READ ONLY, do not modify.

## Auto-Migration

If version < "1.2" or fields missing:
- Add current.loopState = "idle" if missing
- Add current.lastAction = null if missing
- Add patterns = { manualTasks: [], lastPatternAnalysis: null } if missing
- Note: Do NOT save changes (read-only command), just use defaults

## Output Format (3 Lines Only)

LAST: [from current.lastAction.description, or "None" if null]
NOW:  [based on loopState - see below]
DO:   [command to call - see below]

## State Logic

| loopState | NOW shows | DO shows |
|-----------|-----------|----------|
| idle | "No active task" | /next |
| assigned | "Task ready: [humanTask.description]" | /do |
| executing | "Executing: [humanTask.description]" | /done |

## Examples

If loopState is "idle" and lastAction was completing a task:

    LAST: Completed "Send outreach to founders"
    NOW:  No active task
    DO:   /next

If loopState is "assigned":

    LAST: Called /next
    NOW:  Task ready: "Call John at Acme"
    DO:   /do

If loopState is "executing":

    LAST: Started task
    NOW:  Executing: "Call John at Acme"
    DO:   /done

## Check Background AI Tasks

If current.aiTasks has any tasks with status "running":

1. Use TaskOutput with block=false for each taskId
2. Check if still running or completed
3. Add AI status section to output

## Output with AI Tasks Running

    LAST: [lastAction.description]
    NOW:  [based on loopState]
    DO:   [command]

    AI WORKING:
      ⋯ [task 1] (Xm)
      ⋯ [task 2] (Ym)

## Output with AI Tasks Completed (since last check)

    LAST: [lastAction.description]
    NOW:  [based on loopState]
    DO:   [command]

    AI DONE:
      ✓ [task 1]
      ✓ [task 2]

## Key Principle

**Core is 3 lines.** AI status only shows if tasks are running/completed.

The human should instantly know:
1. What they just did
2. Where they are now
3. What to call next
4. What AI is doing in parallel

Zero cognitive load. True parallelism visibility.
