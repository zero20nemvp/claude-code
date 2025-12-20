---
description: "Read-only status check - safe to call multiple times"
allowed-tools:
  - Read
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

## Key Principle

**3 lines only.** No headers, no extras, no AI task status.

The human should instantly know:
1. What they just did
2. Where they are now
3. What to call next

Zero cognitive load.
