# /next - Strategic Task Selection

**Your job: Trust the process. Don't think. Just execute.**

This command analyzes ALL goals to find the MOST EFFICIENT task - the one that makes maximum progress toward completion.

---

## Instructions

### Step 1: Load Complete Goal Landscape

Read ALL goals, not just active:
- `dev/agentme/goals.json` - Complete file
- `dev/agentme/state.json` - Current state
- `dev/agentme/velocity.json` - Performance data

**Include:**
- Active goals (primary)
- Shelved goals (lower priority, but consider)
- All milestones (completed and incomplete)

### Step 2: Extract Task Candidates

From ALL incomplete milestones across ALL goals, generate potential tasks:

**For each milestone with progress < 100%:**
1. Look at remaining acceptance criteria
2. Generate 1-3 specific, actionable tasks
3. Add to candidate pool

**Candidate format:**
```javascript
{
  taskId: "candidate-{goalId}-{milestoneId}-{n}",
  description: "Specific actionable task",
  goalId: "goal-XXX",
  goal Name: "...",
  milestoneId: "mX",
  milestoneName: "...",
  acceptanceCriteria: [...remaining criteria...],
  estimatedPoints: X,
  estimatedBlocks: Y
}
```

**Total candidates:** Usually 20-50 tasks across all goals

### Step 3: STRATEGIC ANALYSIS - Score Each Task

For EACH candidate task, calculate strategic score using these criteria:

#### 3a. **Leverage Analysis** (Weight: 3.0)

How many goals does this help?

```javascript
// Check if task helps multiple goals
leverageScore = 0

// Direct goal
leverageScore += 1.0

// Shared dependencies (e.g., auth needed by 3 goals)
otherGoalsNeedingThis = findGoalsBlockedBySimilarWork(task)
leverageScore += otherGoalsNeedingThis.length * 1.5

// Tasks it unlocks
tasksUnblocked = countTasksBlockedByThis(task)
leverageScore += (tasksUnblocked / 10) * 1.0

leverageMultiplier = leverageScore
```

**Examples:**
- Auth service needed by 3 goals → leverage = 5.5
- UI component for 1 goal only → leverage = 1.0
- Deployment setup unlocks 8 tasks → leverage = 2.8

#### 3b. **Critical Path Analysis** (Weight: 2.0)

Is this blocking important work?

```javascript
criticalPathScore = 0

// Is this milestone on critical path to goal completion?
if (isOnCriticalPath(task.goalId, task.milestoneId)) {
  criticalPathScore += 2.0
}

// Does this goal have an approaching deadline?
daysToDeadline = getDaysToDeadline(task.goalId)
if (daysToDeadline < 7) {
  criticalPathScore += 3.0
} else if (daysToDeadline < 14) {
  criticalPathScore += 1.5
}

// Is this blocking other high-value milestones?
if (blocksHighValueWork(task)) {
  criticalPathScore += 1.0
}
```

#### 3c. **Efficiency (ROI)** (Weight: 1.5)

Bang for buck - impact vs effort

```javascript
// Estimate points for this task
estimatedPoints = estimateTaskPoints(task)

// Estimate blocks using velocity
estimatedBlocks = estimatedPoints / currentVelocity

// Calculate efficiency ratio
efficiency = estimatedPoints / estimatedBlocks

// Higher = better ROI
// Example: 5 points / 2 blocks = 2.5 efficiency
```

#### 3d. **Automation Potential** (Weight: 1.0)

Can Claude do this NOW?

```javascript
// Estimate automation % based on task type
automationPercent = estimateAutomation(task)

// Prioritize high-automation tasks
automationScore = automationPercent / 100

// 100% automatable = 1.0
// 50% automatable = 0.5
// 0% automatable = 0.0
```

**Estimation heuristics:**
- Code/tests/docs → 90% automatable
- Deployment (no MCP) → 30% automatable
- Deployment (with MCP) → 95% automatable
- Design decisions → 10% automatable
- Stakeholder meetings → 0% automatable

#### 3e. **Deadline Pressure** (Weight: 2.5)

Time sensitivity

```javascript
deadlineScore = 0

goal = getGoal(task.goalId)
if (!goal.deadline) {
  deadlineScore = 0.5 // Low priority if no deadline
} else {
  daysLeft = getDaysToDeadline(goal.deadline)

  if (daysLeft < 3) {
    deadlineScore = 5.0 // URGENT
  } else if (daysLeft < 7) {
    deadlineScore = 3.0 // High priority
  } else if (daysLeft < 14) {
    deadlineScore = 1.5 // Medium priority
  } else {
    deadlineScore = 0.5 // Low priority
  }
}

// Front of mind goals get bonus
if (goal.frontOfMind) {
  deadlineScore += 1.0
}
```

#### 3f. **Obstacle Resolution** (Weight: 1.5)

Does this remove blockers?

```javascript
obstacleScore = 0

// Check if task addresses a known obstacle
goal = getGoal(task.goalId)
for (obstacle of goal.obstacles) {
  if (taskAddressesObstacle(task, obstacle)) {
    obstacleScore += 1.0
  }
}

// Check if task enables parallel work
if (createsParallelWorkOpportunities(task)) {
  obstacleScore += 0.5
}

// De-risks other work
if (reducesUncertainty(task)) {
  obstacleScore += 0.5
}
```

#### 3g. **Calculate Final Score**

```javascript
finalScore = (
  leverageMultiplier * 3.0 +
  criticalPathScore * 2.0 +
  efficiency * 1.5 +
  automationScore * 1.0 +
  deadlineScore * 2.5 +
  obstacleScore * 1.5
)

// Normalize to 0-10 scale
normalizedScore = Math.min(10, finalScore / 2)
```

### Step 4: Rank and Select

1. **Sort all candidates by score** (highest first)
2. **Select top task** (highest score)
3. **Identify top alternatives** (next 3-5 tasks)

### Step 5: Generate Task Description

For the selected task, create detailed description:

```
STRATEGIC TASK ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Analyzed: [N] potential tasks across [M] goals

🎯 RECOMMENDED: [Task description] (score: [X.X]/10)

Goal: [goal-name] ([goal-id])
Milestone: [milestone-name] ([progress]%)
Points: [X] | Estimated: [Y] blocks

STRATEGIC VALUE:
[For each non-zero scoring dimension, explain:]
✅ Leverage: [How it helps multiple goals/unlocks tasks]
✅ Critical path: [Why it's time-sensitive]
✅ Efficiency: [Points/blocks ratio]
✅ Automation: [X]% automatable
✅ Deadline: [Days to deadline / urgency]
✅ De-risks: [Obstacles it removes]

UNLOCKS:
[List of tasks/milestones this enables]
- [goal-id-milestone]: [what becomes available]

ALTERNATIVES CONSIDERED:
2. [Alternative 1] (score: [X.X]) - [Why lower priority]
3. [Alternative 2] (score: [X.X]) - [Why lower priority]
4. [Alternative 3] (score: [X.X]) - [Why lower priority]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This is the most efficient path to your goals.

Trust the process. Ready to execute? Use /do
```

### Step 6: Update State

Update `dev/agentme/state.json`:

```json
{
  "humanTask": {
    "taskId": "[generated-task-id]",
    "description": "[task description]",
    "goalId": "[goal-id]",
    "milestoneId": "[milestone-id]",
    "points": X,
    "estimatedBlocks": Y,
    "assignedAt": "[ISO timestamp]",
    "status": "assigned",
    "strategicScore": X.X,
    "scoringBreakdown": {
      "leverage": X.X,
      "criticalPath": X.X,
      "efficiency": X.X,
      "automation": X.X,
      "deadline": X.X,
      "obstacle": X.X
    }
  },
  "lastAnalysis": {
    "candidatesConsidered": N,
    "goalsAnalyzed": M,
    "topAlternatives": [...]
  }
}
```

---

## Scoring Examples

### Example 1: High-Leverage Task

```
Task: Build authentication service
- Leverage: 3 goals need this (score: 5.5 × 3.0 = 16.5)
- Critical path: Yes (score: 2.0 × 2.0 = 4.0)
- Efficiency: 5pts / 2blocks = 2.5 (× 1.5 = 3.75)
- Automation: 85% (× 1.0 = 0.85)
- Deadline: 7 days (× 2.5 = 7.5)
- Obstacle: Removes auth uncertainty (× 1.5 = 1.5)

Total: 34.1 / 2 = 10.0/10 ⭐⭐⭐⭐⭐
```

### Example 2: Low-Priority Task

```
Task: Add animations to sidebar
- Leverage: 1 goal, no unlocks (score: 1.0 × 3.0 = 3.0)
- Critical path: No (score: 0.0 × 2.0 = 0.0)
- Efficiency: 2pts / 3blocks = 0.67 (× 1.5 = 1.0)
- Automation: 60% (× 1.0 = 0.6)
- Deadline: 30 days (× 2.5 = 1.25)
- Obstacle: None (× 1.5 = 0.0)

Total: 5.85 / 2 = 2.9/10 ⭐⭐
```

### Example 3: Medium-Value Task

```
Task: Setup CI/CD pipeline
- Leverage: Helps future tasks, not current goals (score: 1.5 × 3.0 = 4.5)
- Critical path: Not blocking anything immediate (score: 0.5 × 2.0 = 1.0)
- Efficiency: 3pts / 4blocks = 0.75 (× 1.5 = 1.125)
- Automation: Need skill - deployment MCP (30% × 1.0 = 0.3)
- Deadline: No deadline (× 2.5 = 1.25)
- Obstacle: De-risks deployments (× 1.5 = 1.5)

Total: 9.675 / 2 = 4.8/10 ⭐⭐⭐
```

---

## Key Principles

### 1. **Trust-Worthy**
User should be able to call `/next` and trust the recommendation without second-guessing.

### 2. **Transparent**
Show the reasoning so user understands WHY this task was chosen.

### 3. **Adaptive**
Re-analyzes after every `/done` - priorities shift as work completes.

### 4. **Strategic**
Not just "next in queue" - find the MOST EFFICIENT path to goals.

### 5. **Leverage-Seeking**
Actively looks for tasks that help multiple goals simultaneously.

---

## Special Cases

### No Clear Winner

If top 3 tasks have similar scores (within 0.5):

```
STRATEGIC ANALYSIS: Multiple good options

🎯 TOP CANDIDATES:
1. [Task A] (score: 7.2) - [Brief reasoning]
2. [Task B] (score: 7.0) - [Brief reasoning]
3. [Task C] (score: 6.9) - [Brief reasoning]

All are strategically valuable. Recommending #1 for:
[Tiebreaker reasoning - e.g., higher automation, earlier deadline]

Proceed with /do, or tell me which you prefer.
```

### All Tasks Low Automation

If best task is <50% automatable:

```
⚠️  AUTOMATION ALERT

Recommended task is only 40% automatable.

SKILL GAP: Deployment MCP would increase to 90%

OPTIONS:
1. Proceed with 40% automation (I'll do what I can)
2. Acquire deployment MCP first (higher priority)
3. Pick alternative with higher automation

What would you like to do?
```

### Deadline Crisis

If any goal has deadline <3 days:

```
🚨 DEADLINE ALERT

goal-001 deadline in 2 days!

CRITICAL PATH ANALYSIS:
Remaining: 3 tasks, estimated 8 blocks (16 hours)
Available time: ~16 hours

Recommending: [Most critical task on path]

This is urgent. Proceed immediately with /do
```

---

## The Result

**User experience:**
1. Call `/next`
2. See: "This is the most efficient task"
3. Trust it
4. Call `/do`
5. Execute
6. Call `/done`
7. Repeat

**Zero cognitive load. Total trust. Just execute.**

---

## SAFETY RULES (Unbreakable)

**PROTECT THE HUMAN AT ALL TIMES.**

### Core Principle: Augment Human Knowledge

**The human doesn't know what they don't know - that's why you exist.**

**Your role:**
- ✅ Use your knowledge to EXPAND theirs
- ✅ Warn about risks they might not see
- ✅ Suggest better approaches they might not know
- ✅ Protect from dangers they're unaware of
- ✅ Teach through implementation

**NOT:**
- ❌ Be limited by their knowledge
- ❌ Blindly follow if it leads to danger
- ❌ Assume they know best practices
- ❌ Stay silent about better approaches

**Example:**
- They ask: "Recommend next task"
- You see: Task A looks good, but Task B unlocks 3 goals they didn't realize
- You do: Recommend Task B + explain the leverage they couldn't see

### What to BLOCK

**NEVER recommend tasks that:**
- Violate laws (hacking, unauthorized access, piracy, fraud)
- Create intentional security vulnerabilities
- Harm users or expose their data
- Implement malicious functionality
- Violate ethical standards

### What to FLAG

**WARN about tasks involving:**
- Security-sensitive operations (auth, payments, data handling)
- External API integrations (review security)
- User data processing (ensure privacy)

Output warning:
```
⚠️  SECURITY CONSIDERATION

This task involves [security-sensitive area].

SAFEGUARDS TO IMPLEMENT:
- [Protection 1]
- [Protection 2]

Proceeding with security-first approach.
```

### What to TRUST

**DO NOT micro-manage:**
- File operations (git protects us)
- Code refactoring
- Technical decisions
- Architecture choices

**Philosophy:** Automate aggressively, protect from harm, trust git as safety net.

---

## Error Handling

- **No tasks available**: All goals complete - celebrate!
- **All tasks blocked**: Identify blocker, suggest resolving it
- **Scoring ties**: Use tiebreaker logic, offer choice
- **Low automation**: Warn, suggest skill acquisition
- **Illegal/unethical task**: REFUSE, explain why, suggest legal alternative