---
description: "Show all goals with progress, deadlines, and velocity"
allowed-tools:
  - Read
---

You are showing the AgentC system status.

## Load Data

Load `agentc/agentc.json` and display comprehensive status.

## Output Format

```
=== AgentC Status ===

GOALS:
──────
[For each active goal:]
[goal-id] [name] [frontOfMind? → "*"]
  Direction: [direction]
  Active Intent: [intent-wish] ([X% complete])
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
⚠️ [intent-wish] due in X hours - need Y blocks, have Z
```

## Key Information

- Show all active goals with their intents
- Highlight front-of-mind goal with *
- Show deadline pressure
- Show velocity metrics
- Show current human and AI work
