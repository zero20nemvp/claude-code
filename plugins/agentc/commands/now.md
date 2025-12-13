---
description: "Read-only status check - safe to call multiple times"
allowed-tools:
  - Read
---

You are showing current work status (read-only, no state changes).

## Load Data

Load `agentc/agentc.json` - READ ONLY, do not modify.

## Output Format

```
=== Now ===

Your Task: [description]
  Status: [assigned/in_progress]
  Intent: [goal-name] → [intent-wish]
  [Started Xm ago / Not started]

AI Working:
  → [task 1] (Xm)
  → [task 2] (Ym)

Next: [Run /do to start | Continue working | Run /done when complete]
```

## If No Task Assigned

```
=== Now ===

No task assigned.

AI Working:
  → [task 1] (Xm)
  [or: No AI tasks running]

Next: Run /next to get a task
```

## Key Principle

**Read-only** - This command never modifies state.
Safe to call multiple times without side effects.
