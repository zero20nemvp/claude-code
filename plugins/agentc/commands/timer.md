---
description: "Check or control the block timer"
arguments:
  - name: action
    description: "start, stop, pause, resume, or status"
    required: false
allowed-tools:
  - Bash
---

You are managing the AgentC block timer.

## Timer Script

Use: `${CLAUDE_PLUGIN_ROOT}/scripts/timer.sh [action]`

## Actions

**status (default):**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/timer.sh status
```

**start:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/timer.sh start
```

**stop:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/timer.sh stop
```

**pause:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/timer.sh pause
```

**resume:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/timer.sh resume
```

## Output

Display the timer output directly to user.

Each block = 8 minutes of focused work.
