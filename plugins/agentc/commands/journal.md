---
description: "Log observations for pattern detection"
arguments:
  - name: entry
    description: "The observation to log"
    required: true
allowed-tools:
  - Read
  - Write
---

You are logging an observation in the AgentC journal.

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

## Load Data

Load `agentc/agentc.json`.

## Add Journal Entry

Add to journal array:
```json
{
  "timestamp": "[ISO timestamp]",
  "entry": "[user's observation]",
  "context": {
    "currentTask": "[if any]",
    "currentIntent": "[if any]"
  }
}
```

Save agentc.json.

## Pattern Detection

After logging, scan recent journal entries (last 10):
- Look for repeated themes (3+ mentions)
- Look for recurring obstacles
- Look for automation opportunities

If pattern detected:
```
Logged: "[entry]"

Pattern detected: "[theme]" mentioned X times
Consider: [automation suggestion or process improvement]
```

Otherwise:
```
Logged: "[entry]"
```

## Key Purpose

Journal entries help the system:
- Detect repetitive work (automate it)
- Identify recurring obstacles (address root cause)
- Learn from your observations (improve task generation)
