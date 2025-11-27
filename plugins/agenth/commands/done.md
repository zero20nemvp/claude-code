You are recording task completion in the AgentH autonomous system.

Expected format: `/done [X]` where X is the number of 8-minute blocks used (optional if timer is running).

## Directory Detection

Check if `agenth/` exists, else check `agentme/`. Use as `$DIR`.

## STEP 0: Check for Lightweight Tracking Mode

**Check `$DIR/state.json` for `tracking: true`**

If `tracking: true` is set, this is a lightweight block tracking session (started via `/track`).
Use the **LIGHTWEIGHT COMPLETION FLOW** below instead of the standard flow.

---

## INTELLIGENT ATTRIBUTION FLOW (when tracking: true)

This flow analyzes your commit and intelligently attributes work to existing goals or creates retroactive goals.

### A1: Stop Timer & Get Blocks

Stop timer via `turg/plugins/agenth/timer.sh stop`:
- Parse "Blocks: N" from output
- If timer not running and X parameter provided, use X

### A2: Analyze Commit (Commit Context Extraction)

Extract work context from the most recent commit:

```bash
# Get commit subject
SUBJECT=$(git log -1 --format='%s')

# Get commit body
BODY=$(git log -1 --format='%b')

# Get changed files
FILES=$(git log -1 --name-only --format='')

# Get diff stats
STATS=$(git diff HEAD~1..HEAD --stat 2>/dev/null)
```

Build **work context object**:
```json
{
  "subject": "[commit subject line]",
  "body": "[commit body if exists]",
  "files": ["list", "of", "changed", "files"],
  "keywords": ["extracted", "keywords", "from", "subject", "and", "files"],
  "pathPatterns": {
    "agenth": [count of agenth/ files],
    "agentme": [count of agentme/ files],
    "other": [count of other files]
  }
}
```

**Keyword extraction:**
- Split subject on spaces, remove common words (the, a, an, to, for, with, and, or)
- Extract file extensions (.md, .json, .ts)
- Extract directory names from paths
- Clean conventional commit prefixes (feat:, fix:, docs:, etc.)

**If no commit found:** Prompt user for task description, skip to A6 with manual attribution.

### A3: Load All Goals & Intents

Load from BOTH systems:
- `agentme/goals.json` + `agentme/intents.json` (life goals)
- `agenth/goals.json` + `agenth/intents.json` (construction goals)

Filter to:
- Goals where `status !== "shelved"` AND `status !== "completed"`
- Intents where `status === "active"`

### A4: Score Goal/Intent Matches

For each active goal and intent, calculate relevance score:

**Scoring algorithm:**
```
score = 0

# Name similarity (0-40 points)
- Exact keyword match in goal.name or goal.direction: +20 each
- Partial match (substring): +10 each

# File path patterns (0-30 points)
- If agenth/ files changed AND goal.goalType === "construction": +30
- If agentme/ files changed AND goal is life goal: +30
- Path contains goal-related directory: +15

# Intent match bonus (0-30 points)
- Commit keywords match intent.wish words: +15 per match (max 30)
- Commit keywords match milestone names: +10 per match (max 20)

# Normalize to 0-1 scale
finalScore = min(score / 100, 1.0)
```

Return ranked list: `[{goal, intent, score}, ...]`

### A5: Attribution Decision

**High confidence (score > 0.7):**
- Auto-attach to top match
- Display: "Auto-attributed to: [goal-name] → [intent-wish]"

**Medium confidence (0.4 ≤ score ≤ 0.7):**
- Use AskUserQuestion to present top 3 matches:
  ```
  Which goal does this work belong to?

  Options:
  1. [goal-name] ([score]%) - [direction snippet]
  2. [goal-name] ([score]%) - [direction snippet]
  3. [goal-name] ([score]%) - [direction snippet]
  4. Create new goal from this commit
  ```
- If user selects existing: attribute to that goal/intent
- If user selects "Create new": proceed to A5b

**Low confidence (score < 0.4):**
- Proceed to A5b (create retroactive goal)

### A5b: Create Retroactive Goal + Intent

**Determine target system:**
- If `pathPatterns.agenth > pathPatterns.agentme`: → `agenth/`
- Else: → `agentme/`

**Generate goal:**
```json
{
  "id": "[next goal-id in target system]",
  "name": "[Clean commit subject - remove prefixes like 'feat:', 'fix:']",
  "direction": "Toward [derived from commit subject]",
  "current_state": ["Work completed: [commit subject]"],
  "goalType": "[construction if agenth/, otherwise infer from content]",
  "frontOfMind": false,
  "status": "active"
}
```

**Generate completed intent:**
```json
{
  "id": "[next intent-id]",
  "goalId": "[new goal id]",
  "wish": "[commit subject]",
  "outcome": ["[commit subject] - completed"],
  "obstacles": [],
  "plan": [],
  "milestones": [
    {
      "id": "m1",
      "name": "Initial work",
      "description": "[commit body or subject]",
      "acceptance_criteria": ["Work committed"],
      "status": "completed",
      "progress": 100
    }
  ],
  "status": "completed",
  "completedAt": "[now]",
  "created": "[now]"
}
```

**Confirm with user:**
```
Creating retroactive goal from commit:

Goal: [name]
Direction: [direction]
Intent: [wish] (completed)

Confirm? [Yes / Edit name / Cancel]
```

### A6: Generate Task ID

Read velocity.json from the TARGET system (where goal lives):
- Find highest taskId number
- New taskId = "t" + (highest + 1)

### A7: Record to Velocity

Add to velocity.json (in the correct system - agenth/ or agentme/):
```json
{
  "taskId": "[generated taskId]",
  "task": "[commit subject]",
  "goalId": "[matched or created goal id]",
  "intentId": "[matched or created intent id]",
  "goalType": "[from goal]",
  "points": null,
  "estimatedBlocks": null,
  "actualBlocks": [blocks from timer],
  "completedAt": "[ISO timestamp]",
  "milestones": [{"goalId": "...", "milestoneId": "m1", "intentId": "..."}],
  "notes": "Retroactively attributed from /track"
}
```

Update velocity totals:
- totalBlocksUsed += actualBlocks
- tasksCompleted += 1

### A8: Clear Tracking State

Update state.json (in the system that was used):
- Set `tracking: false` or remove field
- Remove `trackingStartedAt`
- Update `lastUpdated`

### A9: Output Summary

```
Work attributed successfully

Commit: [subject]
Blocks: [N]

Attributed to:
  Goal: [goal-id] "[name]"
  Intent: [intent-id] "[wish]"
  [NEW if retroactive]

Run /next for your next task
```

**STOP HERE** - Do not continue to standard flow.

---

## STANDARD COMPLETION FLOW (when humanTask exists)

## STEP 1: Get Blocks Used

Try to stop the timer automatically using `turg/plugins/agenth/timer.sh stop`:
- If timer was running:
  - Parse output for "Blocks: N" and extract N
  - Display: "Timer stopped: N blocks used"
  - Use N as actualBlocks value
- If timer not running and X parameter provided:
  - Display: "Manual entry: X blocks used"
  - Use X as actualBlocks value
- If neither timer nor parameter available:
  - Ask user to input blocks manually
  - Display: "Manual entry: [user input] blocks used"

Always show the data source (Timer/Manual) for transparency.

## STEP 2: Load Context

Read:
- `$DIR/state.json` - get humanTask details (taskId, intentId, targetMilestones)
- `$DIR/velocity.json` - get current velocity data and history
- `$DIR/intents.json` - to update milestone progress (NEW: milestones live here, not goals.json)
- `$DIR/goals.json` - to update current_state when milestone completes

## STEP 3: Check for AI Task Completions

**While the human was working, AI agents may have completed tasks.**

1. Check `state.aiTasks` for tasks with status "completed"
2. If any AI tasks completed since last check:
   ```
   While you worked, AI completed:
   ✓ [AI task 1 description]
   ✓ [AI task 2 description]
   ```
3. Update milestone progress for AI-completed tasks in intents.json
4. Archive completed AI tasks (move to aiHistory in velocity.json or remove)

## STEP 4: Milestone Progress Update (Human Task)

**IMPORTANT: Update milestones in intents.json, NOT goals.json**

1. Get intentId from humanTask.targetMilestones
2. Load the intent from `$DIR/intents.json`
3. Ask the human: "Which milestone(s) did this task advance?"
   - Show the targetMilestones from humanTask as suggestions
   - Allow them to add/modify if reality diverged from plan
4. For each selected milestone:
   - Ask: "Estimate progress on this milestone now? (0-100%)"
   - Update milestone.progress in intents.json
   - If progress = 100%, set milestone.status = "completed"
   - If progress > 0 and < 100%, set milestone.status = "in_progress"

## STEP 5: Update Current State

If any milestone was completed (100%):
- Update parent goal's current_state in goals.json to reflect new reality
- This informs future task generation

If ALL milestones for an intent are complete:
- Set intent.status = "completed" in intents.json
- Prompt: "Intent complete! Run /add-intent [goal-id] to create next commitment"

## STEP 6: Velocity Tracking

Update `$DIR/velocity.json`:
- Add to history array:
  ```json
  {
    "taskId": "[from humanTask.taskId, e.g., t4]",
    "task": "[task description]",
    "goalId": "[goal ID]",
    "intentId": "[intent ID]",
    "goalType": "[goal type]",
    "points": N,
    "estimatedBlocks": N,
    "actualBlocks": N,
    "completedAt": "[ISO timestamp]",
    "milestones": [{"goalId": "...", "milestoneId": "...", "intentId": "..."}],
    "notes": "[optional human notes]"
  }
  ```
- Recalculate totalPointsCompleted, totalBlocksUsed
- Recalculate currentVelocity (points/block ratio)
- Recalculate tasksCompleted
- Recalculate estimationAccuracy

## STEP 7: Immediate Analysis for New Work

**CRITICAL: The system never idles after /done**

1. **Analyze all incomplete milestones** in active intents for new tasks
2. **Classify tasks:** AI-executable vs Human-required
3. **Dispatch new AI agents** if AI tasks available (up to 5 parallel)
4. **Identify human blockers** if any URGENT tasks exist

## STEP 8: Update State

Update `$DIR/state.json`:
- Set humanTask = null
- Set taskReasoning = null
- Update aiTasks array (remove completed, add newly dispatched)
- Update workQueue if new tasks queued
- Update lastUpdated and lastCheckIn timestamps

## STEP 9: Output Summary

Display comprehensive completion summary:
```
Task complete: [human task description]
Estimated: X blocks | Actual: Y blocks

Intent progress: intent-XXX "[wish]"
  Milestone: [name] (X% → Y%)

Velocity: Z points/block
```

If milestone completed:
```
Milestone complete: [milestone name]
```

If intent completed:
```
Intent COMPLETE: intent-XXX "[wish]"
All acceptance criteria met!

Goal: goal-XXX "[direction]" continues
Run /add-intent goal-XXX to create next commitment
```

If URGENT human blocker identified:
```
URGENT blocker detected: [description]
Run /next to address immediately
```

If only AI work continuing (no human blocker):
```
AI agents working autonomously
Check /next or /status to see progress
```

## Important Notes

**Milestones are in intents.json:**
- The old format had milestones in goals.json
- New format: milestones live in intents.json
- Goals only have: id, name, direction, current_state, goalType, frontOfMind, status

**Velocity History Format:**
- Each entry has taskId (t1, t2, t3...)
- Each entry has intentId linking to the intent
- This enables intent-level velocity analysis

**Focus on Intents:**
- Intents have concrete acceptance criteria
- Goals are ongoing directions that never complete
- When intent completes, goal's current_state updates
