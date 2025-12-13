---
description: "Set priority override - front-of-mind goal"
arguments:
  - name: goal-id
    description: "Goal ID to focus on, or 'clear' to remove focus"
    required: true
allowed-tools:
  - Read
  - Write
---

You are setting priority focus in AgentC.

## Load Data

Load `agentc/agentc.json`.

## If "clear" argument

1. Find goal with `frontOfMind: true`
2. Set `frontOfMind: false`
3. Save agentc.json

```
Focus cleared. /next will consider all goals equally.
```

## If goal-id argument

1. Validate goal exists and is active
2. Clear any existing frontOfMind
3. Set `frontOfMind: true` on target goal
4. Save agentc.json

```
Focus set: [goal-id] "[goal-name]"

/next will ONLY assign tasks for this goal until cleared.
Run /focus clear to resume multi-goal optimization.
```

## Key Behavior

When a goal has `frontOfMind: true`:
- /next ONLY considers intents for that goal
- All other goals are temporarily deprioritized
- Use for urgent deadlines or critical blockers
