You are showing the AgentH autonomous system status.

Load data from:
1. `$DIR/goals.json` - all active goals with milestones
2. `$DIR/velocity.json` - current velocity metrics
3. `$DIR/state.json` - humanTask, aiTasks, workQueue, last activity

## Display Format

### Autonomous Work in Progress

**If AI agents are working:**
```
=== AI Agents Working ===

Currently running:
  → [AI task 1 description] (running Xm)
  → [AI task 2 description] (running Ym)

Goals advancing:
- goal-xxx: [name] → Milestone N at X%
- goal-yyy: [name] → Milestone M at Y%

Status: ✅ Autonomous work in progress
```

**If work queued:**
```
=== Work Queue ===

URGENT tasks:
  ! [URGENT task 1] → goal-xxx
  ! [URGENT task 2] → goal-yyy

NORMAL tasks:
  - [NORMAL task 1] → goal-xxx
  - [NORMAL task 2] → goal-yyy
```

### Current Human Task

**If humanTask exists:**
```
=== Current Human Task ===

Working on: [task description]
Target: goal-xxx → [milestone name]
Points: X | Estimated: Y blocks
Started: [time ago]
```

### Goal Progress

**For each active goal:**
```
[Goal Name] (goal-xxx)
Deadline: [date] ([X days away])
Front of Mind: [Yes/No]

Milestones:
  ✓ [Milestone 1]: 100% complete
  → [Milestone 2]: 33% in progress  <-- current
  - [Milestone 3]: 0% pending
  - [Milestone 4]: 0% pending

Overall Progress: [average of all milestone progress]%
Status: [On Track / At Risk / Urgent]
```

**Status calculation:**
- Calculate remaining work: sum of (100 - progress) for all milestones
- Estimate blocks remaining based on velocity
- Calculate hours until deadline
- Required velocity = remaining blocks / hours
- Compare to currentVelocity:
  - On Track: required <= current * 1.2
  - At Risk: required > current * 1.2
  - Urgent: deadline < 24 hours

### System Metrics

**Show velocity tracking:**
```
=== System Velocity ===

Human Work (Agent H):
- Current: X.XX points/block
- Tasks completed: X
- Total blocks invested: X
- Estimation accuracy: XX%

AI Work:
- Tasks completed: X
- Autonomous uptime: XX%
- Human dependency ratio: XX% (human tasks / total tasks)
```

**Autonomous uptime calculation:**
- Time with AI tasks running / Total active time
- Shows how much work happens autonomously

**Human dependency ratio:**
- Human tasks completed / (Human tasks + AI tasks)
- Lower is better (more autonomous)

### Last Activity

```
Last updated: [timestamp]
Last check-in: [timestamp]
System mode: Autonomous ✅
```

## Output Order

1. **Autonomous work** (if any AI agents running or work queued)
2. **Current human task** (if assigned)
3. **Goal progress** (all active goals with milestone breakdown)
4. **System metrics** (velocity, completion stats)
5. **Last activity** (timestamps, mode)

## Visual Indicators

Use these for quick scanning:
- ✓ = completed
- → = in progress
- - = pending
- ! = URGENT
- ⚠️ = at risk
- 🚨 = deadline urgent
- ✅ = all good

Keep output concise, scannable, and actionable.
