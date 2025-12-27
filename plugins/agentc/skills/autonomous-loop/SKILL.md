---
name: autonomous-loop
description: Core autonomous execution loop - Claude orchestrates all work, human is an agent in the system
---

# Autonomous Loop

You are the orchestrator. Human is an agent with a task queue, just like AI agents. Your job is to keep all agents productive - dispatching work, tracking completions, and driving toward goal completion.

## Mental Model

```
┌─────────────────────────────────────────────┐
│            Claude (Orchestrator)            │
│                                             │
│   ┌──────────┐    ┌──────────┐             │
│   │ AI Agent │    │ AI Agent │  ...        │
│   │ (bg task)│    │ (bg task)│             │
│   └──────────┘    └──────────┘             │
│                                             │
│   ┌──────────────────────────────────────┐ │
│   │         Human Agent                  │ │
│   │  Queue: [task1, task2, task3]        │ │
│   │  Interface: /next → /do → /done      │ │
│   └──────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## Core Principles

### 1. Retry Before Escalating
Try **at least 3 times** with different approaches before involving human:
- Attempt 1: Standard approach
- Attempt 2: Alternative approach
- Attempt 3: Workaround/different strategy
- Only after 3 failures: Escalate with full failure log

### 2. Ruthless Task Decomposition
Before assigning ANY task to human:
1. Break it down recursively until atomic
2. Extract EVERY piece Claude can do (scripts, tests, prep, verification)
3. Only the irreducible human action goes to queue

### 3. Parallel by Default
- Identify ALL independent tasks
- Dispatch ALL of them simultaneously
- No artificial limits
- Only serialize when there's a true data dependency

### 4. Execution-Ready Human Tasks
Human tasks must be 100% complete - zero thinking required:
- Exact command to run (copy-paste ready)
- Full context already gathered
- Expected output documented
- What to do if it fails

### 5. Continuous Skill Opportunity Detection
For every human task:
- Check: Could a skill/MCP eliminate this task type?
- Log to `metrics.skillOpportunities[]`
- Goal: Reduce human work to zero over time

## Loop Iteration

### STEP 1: Load State

Load `agentc/agentc.json` and check:
- `current.autonomousSession.active` should be `true`
- `current.loopState` should be `"autonomous"`
- Get list of `current.aiTasks` and `current.humanTaskQueue`

### STEP 2: Check AI Task Completions

For each task in `current.aiTasks` with `status: "running"`:

1. Use TaskOutput tool with `block=false` to check status
2. If completed:
   - Update task status to `"completed"`
   - Store result summary
   - Update metrics: `metrics.sessions[current].aiTasksCompleted++`
   - Check if this unblocks any other tasks
3. If still running:
   - Continue (don't wait)
4. If failed:
   - Check retry count
   - If < 3 retries: Re-dispatch with different approach
   - If >= 3 retries: Escalate to human queue with failure log

### STEP 3: Check Human Task Completions

Check if `current.loopState` changed from human calling `/done`:
- If human completed a task, mark it done in queue
- Check what tasks are now unblocked
- Update metrics: `metrics.sessions[current].humanTasksCompleted++`

### STEP 4: Analyze Goals for New Tasks

For each active north star and goal:

1. Check milestone acceptance criteria
2. Identify what's incomplete
3. Generate atomic tasks from codebase reality (not abstract planning)
4. Classify each task:
   - **AI-executable**: Code, tests, documentation, research
   - **Human-required**: External access, physical testing, authority, subjective judgment

### STEP 5: Dispatch AI Tasks (Parallel)

For all AI-executable tasks identified:

1. Check current running count
2. Identify independent tasks (no dependencies on each other)
3. Dispatch ALL independent tasks simultaneously using Task tool:
   ```
   Task tool with run_in_background=true
   ```
4. Log each to `current.aiTasks[]` with status `"running"`
5. Track dependencies: which tasks are blocked on what

### STEP 6: Queue Human Tasks (Execution-Ready)

For each human-required task:

**First, ruthlessly decompose:**
1. Can any part be done by Claude? → Extract and dispatch
2. Can prep work be done? → Do it now
3. Can verification be automated? → Prepare it
4. What's the MINIMUM human action?

**Then, make execution-ready:**
```yaml
taskId: ht-001
description: "Run deployment to production"
command: "ssh user@prod.example.com './deploy.sh v1.2.3'"
expectedOutput: "Deployment complete. Health check passed."
ifFails: "Run ./rollback.sh then notify Claude"
requiredCapability: "external_system_access"
blocking: true  # or false
blocksAgentTasks: ["ai-003", "ai-004"]
```

**Check skill opportunity:**
- Does this match a pattern in `metrics.skillOpportunities`?
- If yes: Increment count
- If new pattern: Add to opportunities
- If count >= 5: Suggest skill creation after completion

**Add to queue:**
- Add to `current.humanTaskQueue[]`
- Send notification via `notify-human.sh`

### STEP 7: Update State

Write updated state to `agentc/agentc.json`:
- Increment `current.autonomousSession.iterationCount`
- Update `current.aiTasks`
- Update `current.humanTaskQueue`
- Update metrics

### STEP 8: Check Loop Conditions

**Goal complete?**
- All milestone acceptance criteria met
- Set `current.autonomousSession.active = false`
- Set `current.loopState = "complete"`
- Notify human: "Goal complete!"
- Exit loop

**All blocked on human?**
- No running AI tasks
- All remaining work requires human
- Set `current.loopState = "waiting_human"`
- Notify human: "Waiting for your input"
- Exit loop (will resume when human calls `/done`)

**Work available?**
- Continue to next iteration

**Error?**
- Log error to state
- Wait 30 seconds
- Retry iteration
- After 3 same errors: Stop and notify human

### STEP 9: Continue Loop

If work available, immediately start next iteration.
Do not wait. Keep all agents productive.

## Error Recovery

```
Loop encounters error
  ↓
Log error to agentc.json with timestamp
  ↓
Wait 30 seconds
  ↓
Retry iteration
  ↓ same error again?
Log retry attempt 2
  ↓
Wait 30 seconds
  ↓
Retry iteration
  ↓ same error 3rd time?
STOP - Set autonomousSession.active = false
Notify human:
  "Autonomous loop stopped after 3 errors: [reason]"
  "State saved. Run /start to resume."
```

## Metrics Updates

After each iteration, update:

```json
{
  "metrics": {
    "sessions": [{
      "aiTasksCompleted": N,
      "humanTasksCompleted": N,
      "retriesBeforeSuccess": N,
      "retriesEscalatedToHuman": N
    }],
    "automationProgress": {
      "currentRatio": aiTasks / (aiTasks + humanTasks),
      "trend": [... previous ratios]
    },
    "capabilityGaps": {
      "[capability]": {
        "humanTaskCount": N,
        "priority": "HIGH|MEDIUM|LOW"
      }
    },
    "skillOpportunities": [{
      "pattern": "description",
      "occurrences": N,
      "impactScore": "HIGH|MEDIUM|LOW"
    }]
  }
}
```

## Human Notification Format

When adding task to human queue, output:

```
════════════════════════════════════════════════════════════
 NEW TASK IN YOUR QUEUE
════════════════════════════════════════════════════════════

 Task: ht-001
 [Description]

 Command to run:
   [exact command]

 Expected output:
   [what to expect]

 If it fails:
   [what to do]

 Run /next to start

════════════════════════════════════════════════════════════
```

Also call `notify-human.sh` for desktop notification.

## Key Reminders

- **Never idle** - Always dispatch or analyze
- **Parallel first** - Serialize only when required
- **Human = minimal** - Extract every Claude-doable piece
- **Execution-ready** - Human just executes, doesn't think
- **Track everything** - Metrics drive improvement toward 100% automation
