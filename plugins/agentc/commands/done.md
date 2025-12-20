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

## STEP 0.5: Stage Task Completion

Check humanTask.type for stage tasks. These skip TDD/verification gates:

**type = "bootstrap" or "create-north-star":**
- Verify North Star was created in agentc.json
- Skip to STEP 8 (Update State)

**type = "create-goal":**
- Verify Goal was created in agentc.json
- Skip to STEP 8 (Update State)

**type = "jtbd":**
- Verify stageProgress.jtbd.status = "done"
- Verify JTBD file exists
- Skip to STEP 8 (Update State)

**type = "stories":**
- Verify stageProgress.stories.status = "done"
- Verify stories file exists
- Skip to STEP 8 (Update State)

**type = "features":**
- Verify stageProgress.features.status = "done"
- Verify feature files exist
- Skip to STEP 8 (Update State)

**type = "slices":**
- Verify stageProgress.slices.status = "done"
- Skip to STEP 8 (Update State)

**type = null or "implementation":**
- Continue to STEP 1 (normal verification flow)

## STEP 1: Get Blocks Used

Try to stop timer by running the timer script with "stop".

- If timer running: Parse "Blocks: N" from output
- If timer not running and blocks argument provided: Use argument
- If neither: Use AskUserQuestion with options: ["1 block", "2 blocks", "3 blocks", "5 blocks", "8 blocks"]

## STEP 2: Verification Evidence Check

**Must have evidence from /do execution:**

Use AskUserQuestion:
- Question: "All verification gates passed?"
- Options: ["Yes, all passed", "No, back to /do"]

**If "No, back to /do":**

    BLOCKED: Verification incomplete.

    DO: /do

## STEP 2.5: Code Review Gate (Non-Blocking)

**Check reviewPending status:**

1. If current.reviewPending = true:
   - Code review was dispatched but hasn't completed
   - Check if review agent has finished

2. If review completed with CRITICAL issues:

       ⚠️ Code review found CRITICAL issue:
       - [issue description]

       Options:
       1. Fix now (recommended)
       2. Proceed anyway (--force)

3. If user chooses --force or "proceed anyway":
   - Log to reviewDebt array with taskId, severity, issue, skippedAt
   - Continue to completion
   - Warn: "Logged to review debt. Address before release."

4. If review completed with no CRITICAL issues:
   - Continue normally

**This gate is NON-BLOCKING with --force.** Human maintains flow state.

## STEP 2.7: Milk Quality Tier Verification

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

## STEP 2.8: RBS Type Gate (Ruby Only)

**Only applies when `humanTask.languageMode = "ruby"`**

**Strict enforcement - block completion if RBS types missing or invalid:**

### 1. Check for RBS signatures

For each modified `.rb` file, verify corresponding `.rbs` exists:

```bash
for rb_file in $(git diff --name-only HEAD~1 | grep '\.rb$'); do
  rbs_file="sig/${rb_file%.rb}.rbs"
  if [ ! -f "$rbs_file" ]; then
    echo "MISSING: $rb_file has no RBS type signature at $rbs_file"
  fi
done
```

### 2. Validate RBS syntax

```bash
bundle exec rbs validate
```

### 3. Type check with Steep (if configured)

```bash
if [ -f "Steepfile" ]; then
  bundle exec steep check
fi
```

**Display RBS gate result:**
```
=== RBS Type Gate ===
✓ All .rb files have .rbs signatures
✓ RBS validation passed
✓ Steep type check passed (if configured)

RBS Requirements: PASSED
```

**If RBS requirements NOT met:**
```
BLOCKED: RBS type requirements not satisfied.

Missing signatures:
- app/models/user.rb → needs sig/app/models/user.rbs
- app/services/order_processor.rb → needs sig/app/services/order_processor.rbs

Validation errors:
- [error details from rbs validate]

Run /do to add missing RBS types before /done.
```

**Do NOT allow completion bypass. This is STRICT enforcement for Ruby projects.**

Update `humanTask.qualityVerification.rbsTypesValid` in agentc.json:
```json
{
  "qualityVerification": {
    "rbsTypesValid": true
  }
}
```

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

## STEP 7: Queue Pop or Next Analysis

**Check humanTaskQueue first:**

1. If humanTaskQueue is NOT empty:
   - Pop first task from queue
   - Set as new humanTask with status = "assigned"
   - Set loopState = "assigned"
   - Skip to STEP 9 with queue-pop output format

2. If humanTaskQueue IS empty:
   - Analyze remaining tasks across active goals
   - Classify: AI-executable vs Human-required
   - Dispatch new AI agents if available (up to 5)
   - Continue to STEP 8 (idle state)

## STEP 7.5: Track Manual Task Patterns

Track recurring patterns for future skill creation:

1. Normalize task description to a pattern (remove specifics like names, numbers)
2. Check patterns.manualTasks for similar patterns
3. If found: increment count, update lastSeen
4. If not found: add new entry with count = 1
5. If count >= 5 AND no skill suggested yet:
   - Note: "SKILL OPPORTUNITY: You've done '[pattern]' 5+ times. Consider creating a skill."

## STEP 8: Update State

**If queue was popped:**
- Set current.loopState = "assigned"
- Set current.lastAction = { action: "done", timestamp: now, description: "Completed: [task], auto-assigned from queue" }
- Set current.humanTask = [popped task from queue]
- Remove popped task from humanTaskQueue
- Set current.reviewPending = false
- Update current.aiTasks (remove completed, add new)
- Update lastCheckIn timestamp

**If queue empty (normal):**
- Set current.loopState = "idle"
- Set current.lastAction = { action: "done", timestamp: now, description: "Completed: [task]" }
- Set current.humanTask = null
- Set current.humanTaskQueue = []
- Set current.reviewPending = false
- Update current.aiTasks (remove completed, add new)
- Update lastCheckIn timestamp

## STEP 9: Output Summary

**If queue was popped (next task auto-assigned):**

    DONE [X blocks]
    [Completed task description]

    NEXT FROM QUEUE [Y pts]
    [Next task description]

    QUEUE:
      2. [remaining queued task]

    DO: /do

**If queue empty (normal idle state):**

    DONE [X blocks]
    [Task description]

    DO: /next

**If review debt was logged:**

    DONE [X blocks]
    [Task description]

    ⚠️ Review debt: 1 CRITICAL issue logged

    DO: /next

No verbose stats. Human trusts the system recorded everything.

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
