---
description: "Record task completion with verification evidence"
arguments:
  - name: blocks
    description: "Number of 8-minute blocks used (optional if timer running)"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

You are recording task completion in the AgentC system with verification requirements.

## Directory Detection

Use `agentc/` as `$DIR`. Load `$DIR/agentc.json`.

## STEP 0: Pre-Completion Verification

**Before recording completion, verify work was done properly:**

1. Check that /do was run (humanTask.status should be "in_progress")
2. If status is still "assigned", warn: "Task not started. Run /do first."

## STEP 1: Get Blocks Used

Try to stop timer:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/timer.sh stop
```

- If timer running: Parse "Blocks: N" from output
- If timer not running and blocks argument provided: Use argument
- If neither: Ask user for manual entry

Display: "Timer stopped: N blocks used" or "Manual entry: N blocks"

## STEP 2: Verification Evidence Check

**Must have evidence from /do execution:**

Ask: "Please confirm the verification results from /do:"

1. **Tests passed?** (yes/no)
2. **Code review passed?** (yes/no, issues fixed)
3. **Changes committed?** (yes/no)
4. **Tier gate passed?** (yes/no) - based on milkQuality tier

**If any NO:**
- "Completion blocked. Run /do to complete task properly."
- Do not record completion

## STEP 2.5: Milk Quality Tier Verification

**Strict enforcement - block completion if tier requirements not met:**

Read `humanTask.milkQuality` and `humanTask.qualityVerification` from agentc.json.

| Tier | Required Fields |
|------|-----------------|
| skimmed | happyCaseTested = true |
| semi-skimmed | happyCaseTested = true, sadCasesTested = true |
| full-phat | All fields = true (happy, sad, mad, logging, monitoring) |

```
=== Milk Quality Verification: [TIER] ===
```

**If requirements NOT met:**
```
BLOCKED: Milk Quality tier requirements not satisfied.

Tier: [TIER]
Missing:
- [ ] [requirement not met]

Run /do to complete tier requirements before /done.
```

**Do NOT allow completion bypass. This is STRICT enforcement.**

## STEP 3: Update Task Status in Plan

1. Find the task in goal.plan.tasks matching humanTask.taskId
2. Set task.status = "completed"
3. Check if all tasks in plan are complete

## STEP 4: Goal Progress Check

Calculate goal completion:
- Count completed tasks vs total tasks
- If all tasks complete: Set goal.status = "completed"

```
Goal progress: [completed]/[total] tasks (X%)
```

If goal complete:
```
GOAL COMPLETE: "[wish]"
All acceptance criteria met!

North Star "[north-star-name]" continues.
Run /add-goal [north-star-id] to create next commitment.
```

## STEP 5: Velocity Tracking

Add to velocity.history:
```json
{
  "taskId": "[humanTask.taskId]",
  "task": "[task description]",
  "northStarId": "[north star id]",
  "goalId": "[goal id]",
  "points": [points],
  "estimatedBlocks": [estimate],
  "actualBlocks": [actual],
  "milkQuality": "[tier]",
  "completedAt": "[ISO timestamp]",
  "verified": true
}
```

Update velocity totals:
- totalPoints += points
- totalBlocks += actualBlocks
- Recalculate currentVelocity (points/block)

## STEP 6: Check AI Task Completions

While human was working, AI agents may have finished:

1. Check current.aiTasks for status "completed"
2. If any completed:
   ```
   While you worked, AI completed:
   ✓ [AI task 1]
   ✓ [AI task 2]
   ```
3. Update those tasks in goal.plan.tasks
4. Archive completed AI tasks

## STEP 7: Immediate Analysis for Next Work

**The system never idles after /done:**

1. Analyze remaining tasks across active goals
2. Classify: AI-executable vs Human-required
3. Dispatch new AI agents if available (up to 5)
4. Identify next human task

## STEP 8: Update State

Update agentc.json:
- Set current.humanTask = null
- Update current.aiTasks (remove completed, add new)
- Update lastCheckIn timestamp

## STEP 9: Output Summary

```
=== Task Complete ===

Task: [description]
Milk Quality: [TIER] ✓
Estimated: X blocks | Actual: Y blocks

Goal progress: [goal-id] "[wish]"
  [completed]/[total] tasks (X%)

Velocity: Z points/block

AI Status:
  ✓ [completed AI tasks]
  → [running AI tasks]

Run /next for your next task.
```

## Key Principles

**Verification is mandatory:**
- Must confirm tests passed
- Must confirm code review passed
- "Should be done" is not acceptable

**Milk Quality gate is STRICT:**
- Block completion if tier requirements not met
- No bypass allowed
- Tier is recorded in velocity history

**System never idles:**
- After /done, immediately analyze for new work
- Dispatch AI agents if tasks available
- Queue next human task

**Honest tracking:**
- Record actual blocks used
- Track estimation accuracy
- Track quality tier per task
- Learn from velocity history
