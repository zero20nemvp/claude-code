You are starting lightweight block tracking - ad-hoc work that should count toward velocity but doesn't need goal/intent overhead.

## What This Does

`/track` starts a timer immediately. When you later run `/done`, it will:
1. Stop the timer and calculate blocks
2. Pull the last git commit message as the task description
3. Record to velocity.json with `goalId: null`

**Zero friction:** No goal, no intent, no milestone. Just tracked blocks.

## STEP 1: Directory Detection

Check if `agenth/` exists, else check `agentme/`. Use as `$DIR`.

## STEP 2: Locate Timer Script

The timer.sh is in the turg plugin directory, not the data directory.
Path: `turg/plugins/agenth/timer.sh` (relative to project root)

## STEP 3: Check Timer State

Check if timer is already running via `turg/plugins/agenth/timer.sh status`:
- If running: "Timer already running. Use `/done` to complete current work first."
- If not running: Continue

## STEP 4: Start Timer

Run the timer using the shell script:
```bash
turg/plugins/agenth/timer.sh start
```

## STEP 5: Update State

Update `$DIR/state.json`:
```json
{
  "lastUpdated": "[ISO timestamp]",
  "activeGoals": [...],
  "humanTask": null,
  "taskReasoning": null,
  "tracking": true,
  "trackingStartedAt": "[ISO timestamp]",
  "autonomousMode": true,
  "aiTasks": [],
  "workQueue": [],
  "lastCheckIn": "[ISO timestamp]"
}
```

**Key:** Set `tracking: true` - this tells `/done` to use the lightweight flow.

## STEP 6: Output

```
Tracking started

Timer running. Work on anything - when done:
1. Commit your work (commit message = task description)
2. Run /done

Blocks will be recorded to velocity with goalId: null
```

## Notes

- No task assignment - just timer
- No goal linkage - pure time tracking
- `/done` will detect `tracking: true` and use lightweight completion flow
- Commit message becomes task description (or prompt if no commit)
