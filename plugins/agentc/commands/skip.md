---
description: "Skip current task to work on a queued task instead"
arguments: []
allowed-tools:
  - Read
  - Write
  - Edit
---

You are handling task skipping in the AgentC system when human is blocked on current task.

## File Locking (Multi-Process Safety)

Before accessing agentc.json, acquire the lock:
```bash
scripts/lock.sh lock agentc/agentc.json
```

**CRITICAL:** Release the lock before completing this command:
```bash
scripts/lock.sh unlock agentc/agentc.json
```

If lock fails: "Another AgentC session may be active."

## Directory Detection

Use agentc/ as $DIR. Load $DIR/agentc.json.

## STEP 1: Validate Skip is Possible

1. Check current.humanTask exists
   - If null: "No task assigned. Run /next first."

2. Check current.humanTaskQueue is not empty
   - If empty: "No queued tasks to skip to. Complete current task or run /next."

3. Check humanTask.status
   - If "assigned" but not started: Can skip
   - If "in_progress": Can skip (mark as blocked)

## STEP 2: Mark Current Task as Blocked

Update current humanTask:

    {
      "humanTask": {
        ...existing fields...,
        "status": "blocked",
        "blockedAt": "[ISO timestamp]",
        "blockedReason": "Skipped to queued task"
      }
    }

Move to a blockedTasks array (create if doesn't exist):

    {
      "blockedTasks": [
        { ...current humanTask with blocked status... }
      ]
    }

## STEP 3: Pop Next Task from Queue

1. Take first task from humanTaskQueue
2. Remove it from queue
3. Set as new humanTask with status = "assigned"

## STEP 4: Update State

Update agentc.json:
- Set current.humanTask = [popped task]
- Set current.humanTaskQueue = [remaining tasks]
- Set current.loopState = "assigned"
- Set current.lastAction = { action: "skip", timestamp: now, description: "Skipped to: [new task]" }

## STEP 5: Output

    SKIPPED
    Previous: [blocked task description] → marked blocked

    NOW [X pts]
    [New task description]

    QUEUE:
      2. [next queued task if any]

    BLOCKED (return later):
      • [blocked task]

    DO: /do

## Key Principles

**Skip preserves blocked tasks:**
- Blocked tasks are not lost
- They remain in blockedTasks array
- /next will resurface them when blockers clear

**Skip is for external blockers:**
- Waiting for deploy to finish
- Waiting for email response
- Waiting for external system access

**Don't skip for task difficulty:**
- If task is hard, work through it
- Skip is for genuine blockers, not avoidance
