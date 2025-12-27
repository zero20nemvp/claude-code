---
description: "Show all north stars with progress, deadlines, and velocity"
allowed-tools:
  - Read
---

You are showing the AgentC system status.

## STEP 0: Auto-Migration

**If old schema detected, migrate first:**
- If `goals[]` exists but `northStars[]` doesn't: rename `goals` → `northStars`
- If `intents[]` exists: rename `intents` → `goals`
- Update all `goalId` references to `northStarId` in goals array
- Save and announce: "Migrated data schema: goals → northStars, intents → goals"

## Load Data

Load `agentc/agentc.json` and display comprehensive status.

## Output Format

**If in autonomous mode (`current.autonomousSession.active == true`):**

```
═══════════════════════════════════════════════════════════════
                    AUTONOMOUS MODE ACTIVE
═══════════════════════════════════════════════════════════════

Goal: [autonomousSession.goalDescription]
Started: [time ago]
Iterations: [iterationCount]

CLAUDE IS WORKING ON:
  ✓ [completed AI task 1]
  ✓ [completed AI task 2]
  ⋯ [running AI task 1] (running Xm)
  ⋯ [running AI task 2] (running Ym)
  ○ [blocked AI task] (waiting for human)

YOUR QUEUE:
  1. [current human task if assigned]
  2. [queued human task 1]
  3. [queued human task 2]

BLOCKED TASKS:
  [AI tasks waiting for human tasks]

═══════════════════════════════════════════════════════════════
                    AUTOMATION PROGRESS
═══════════════════════════════════════════════════════════════

Current: [X]% autonomous (target: 100%)
Trend: [prev1]% → [prev2]% → [prev3]% → [current]% [↑ or ↓]

TOP CAPABILITY GAPS:
  1. [capability] ([N] tasks) → Suggest: [skill/MCP]
  2. [capability] ([N] tasks) → Suggest: [skill/MCP]
  3. [capability] ([N] tasks) → Suggest: [skill/MCP]

RETRY EFFICIENCY:
  [X]% success after retry ([success]/[total])
  [Y] escalated to human

SKILL OPPORTUNITIES:
  🔥 "[pattern]" ([N] occurrences, [impact] impact)

Run /skill to create automations

═══════════════════════════════════════════════════════════════
```

**If NOT in autonomous mode (normal status):**

```
=== AgentC Status ===

NORTH STARS:
────────────
[For each active north star:]
[north-star-id] [name] [frontOfMind? → "*"]
  Direction: [direction]
  Why: [why]
  Active Goal: [goal-wish] ([X% complete])
  Deadline: [date] ([Y days remaining])
  Tasks: [completed]/[total] ([AI running], [human pending])

VELOCITY:
─────────
Current: [X] points/block
Tasks completed: [N]
Estimation accuracy: [X]%

CURRENT WORK:
─────────────
Human Task: [description or "None assigned"]
  Milk Quality: [tier] (skimmed|semi-skimmed|full-phat)
  Tier Progress: [X/Y requirements met]
AI Tasks:
  → [task 1] (running Xm)
  → [task 2] (running Ym)

DEADLINE RISKS:
───────────────
[If any deadlines at risk:]
⚠️ [goal-wish] due in X hours - need Y blocks, have Z

═══════════════════════════════════════════════════════════════
TIP: Run /start to enter autonomous mode
═══════════════════════════════════════════════════════════════
```

## Key Information

- Show all active north stars with their goals
- Highlight front-of-mind north star with *
- Show deadline pressure
- Show velocity metrics
- Show current human and AI work
