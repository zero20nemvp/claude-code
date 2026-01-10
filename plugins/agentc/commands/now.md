---
name: now
description: "What's happening now? Use --full for comprehensive view"
arguments:
  - name: flag
    description: "--full for comprehensive view"
    required: false
allowed-tools:
  - Read
  - Write
  - TaskOutput
---

You are showing current AgentC state.

## Load Data

Load `agentc/agentc.json` - create if doesn't exist.

## Auto-Migration

If old schema detected:
- If `goals[]` exists but `northStars[]` doesn't: rename `goals` → `northStars`
- If `intents[]` exists: rename `intents` → `goals`
- Save and announce migration

## Route by Argument

**No argument (default):** Quick 3-line status
**--full:** Comprehensive view

---

## DEFAULT: Quick Status (3 lines)

```
LAST: [current.lastAction.description or "None"]
NOW:  [based on loopState - see table]
DO:   [next command - see table]
```

| loopState | NOW shows | DO shows |
|-----------|-----------|----------|
| idle | "No active task" | /next |
| assigned | "Task ready: [humanTask.description]" | /do |
| executing | "Executing: [humanTask.description]" | /done |
| autonomous | "Autonomous mode active" | /now --full |

**If AI tasks running, append:**
```
AI:
  ⋯ [task description] (Xm)
```

**If AI tasks completed since last check:**
```
AI:
  ✓ [task description]
```

---

## --full: Comprehensive View

**If autonomous mode:**

```
═══════════════════════════════════════════════════════════════
                    AUTONOMOUS MODE
═══════════════════════════════════════════════════════════════

Goal: [autonomousSession.goalDescription]
Started: [time ago]
Iterations: [iterationCount]

CLAUDE:
  ✓ [completed AI task]
  ⋯ [running AI task] (Xm)
  ○ [blocked - waiting for human]

YOU:
  1. [current human task if assigned]
  2. [queued human task 1]

═══════════════════════════════════════════════════════════════
```

**If NOT autonomous mode:**

```
=== AgentC ===

NORTH STARS:
[ns-id] [name] [frontOfMind? → "*"]
  → [goal-wish] ([X%]) due [date]

VELOCITY:
[N] tasks / [M] blocks

NOW:
[description or "No task"]

DO: [next command]
```

---

## Key Principles

- **Default is quick** - 3 lines, zero cognitive load
- **Full on demand** - When you need the big picture
- **Always show DO:** - System tells you what's next
