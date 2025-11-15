# /status - Show Current Status

Displays comprehensive status: timer, current task, progress, and blocks completed today.

## Instructions

### Step 1: Read Timer State

Check if `dev/agentme/timer-state.json` exists and read it.

Extract:
- `running`: true/false
- `pausedAt`: null or timestamp
- `_startEpoch`: start time
- `elapsedBlocks`: blocks completed
- `lastNotifiedBlock`: last notification

Calculate current elapsed time and block progress:
```bash
cd /Users/db/Desktop/agentme/dev/agentme && ./timer.sh status
```

Parse output for:
- Timer status (running/paused/stopped)
- Elapsed time
- Completed blocks
- Current block progress (X/8 minutes)

### Step 2: Read Current Task

Read `dev/agentme/state.json` to get:
- `humanTask`: current task details (if any)
  - description
  - goalId, milestoneId
  - points, estimatedBlocks
  - status (assigned, in_progress)
  - assignedAt, startedAt

### Step 3: Read Today's Progress

Read `dev/agentme/velocity.json` and count tasks completed today:
- Filter `history` array for entries where `completedAt` is today's date
- Sum up blocks from those entries

### Step 4: Read Goal Progress

If humanTask exists:
- Read `dev/agentme/goals.json`
- Find the goal by goalId
- Find the milestone by milestoneId
- Get milestone progress percentage

### Step 5: Display Status

Format output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ AGENTH STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏱️  TIMER
   Status: [Running ⏱️ | Paused ⏸️ | Stopped ⏹️]
   Elapsed: [X]m [Y]s
   Blocks completed: [Z]
   Current block: [A]/8 minutes
   [If paused: "Paused at [time]"]

📋 CURRENT TASK
   [If no task: "No task assigned - use /next"]
   [If task assigned but not started:
    Task: [description]
    Goal: [goal-name]
    Milestone: [milestone-name] ([progress]%)
    Estimated: [X] blocks
    Status: Ready to start - use /do
   ]
   [If task in progress:
    Task: [description]
    Goal: [goal-name]
    Milestone: [milestone-name] ([progress]%)
    Estimated: [X] blocks | On track: [Yes ✅ / Behind ⚠️ / Ahead 🚀]
    Started: [time ago]
    Status: In progress - use /done when complete
   ]

📊 TODAY'S PROGRESS
   Blocks completed: [count]
   Tasks finished: [count]
   Current velocity: [X.XX] points/block

🎯 ACTIVE GOALS ([count])
   [List active goals with progress bar]
   [goal-name]: [███████░░░] [progress]%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKFLOW: /next → /do → /done
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Calculation: On Track Status

Compare elapsed blocks to estimated blocks:
- If current blocks ≤ estimated: "On track ✅" or "Ahead 🚀"
- If current blocks > estimated: "Behind ⚠️ (+X blocks over)"

### Today's Date Calculation

Filter for tasks completed where:
```javascript
completedAt.startsWith(TODAY_ISO_DATE)  // e.g., "2025-11-15"
```

### Progress Bar Rendering

For milestone progress percentage:
- 0-10%: [░░░░░░░░░░]
- 11-20%: [██░░░░░░░░]
- 21-30%: [███░░░░░░░]
- etc.

Use 10 blocks total, fill proportional to percentage.

## Quick Status Option

For a minimal version, just show:
```
⏱️  [Running: 12m 34s | Block 2/8] | 📋 Task: [description] | 🎯 [goal-name]
```

## Error Handling

- No timer state file: Show "Timer not running"
- Corrupted timer state: Show error and suggest starting fresh
- No current task: Show reminder to use /next
- State files missing: Show setup instructions
