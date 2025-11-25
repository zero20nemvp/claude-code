You are recording task completion in the AgentH autonomous system.

Expected format: `/done [X]` where X is the number of 8-minute blocks used (optional if timer is running).

## Directory Detection

Check if `agenth/` exists, else check `agentme/`. Use as `$DIR`.

## STEP 1: Get Blocks Used

Try to stop the timer automatically using `./$DIR/timer.sh stop`:
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
