---
description: "Set priority override - front-of-mind north star"
arguments:
  - name: north-star-id
    description: "North Star ID to focus on, or 'clear' to remove focus"
    required: true
allowed-tools:
  - Read
  - Write
---

You are setting priority focus in AgentC.

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

## STEP 0: Auto-Migration

**If old schema detected, migrate first:**
- If `goals[]` exists but `northStars[]` doesn't: rename `goals` → `northStars`
- If `intents[]` exists: rename `intents` → `goals`
- Update all `goalId` references to `northStarId` in goals array
- Save and announce: "Migrated data schema: goals → northStars, intents → goals"

## Load Data

Load `agentc/agentc.json`.

## If "clear" argument

1. Find north star with `frontOfMind: true`
2. Set `frontOfMind: false`
3. Save agentc.json

```
Focus cleared. /next will consider all north stars equally.
```

## If north-star-id argument

1. Validate north star exists and is active
2. Clear any existing frontOfMind
3. Set `frontOfMind: true` on target north star
4. Save agentc.json

```
Focus set: [north-star-id] "[north-star-name]"

/next will ONLY assign tasks for this north star until cleared.
Run /focus clear to resume multi-north-star optimization.
```

## Key Behavior

When a north star has `frontOfMind: true`:
- /next ONLY considers goals for that north star
- All other north stars are temporarily deprioritized
- Use for urgent deadlines or critical blockers
