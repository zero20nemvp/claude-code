---
description: Pause/shelve a goal to remove it from active task selection
---

You are shelving (pausing) a goal in the AgentH system.

A shelved goal:
- Remains in goals.json but marked as inactive
- Does NOT appear in /next task selection
- Does NOT show in /status by default
- Can be unshelved later to resume work

**Step 1: Show Active Goals**
Read `$DIR/goals.json` and display all active goals with:
- Goal ID and name
- Current progress (points completed / total points)
- Deadline

**Step 2: Get User Selection**
Ask which goal to shelve (by ID or number selection).

**Step 3: Confirm Shelving**
Show:
- Goal being shelved
- Current progress
- Reason for shelving (ask user: "Why are you shelving this goal?")

**Step 4: Update Data**
1. Read `$DIR/goals.json`
2. Add `"status": "shelved"` and `"shelvedAt": "[timestamp]"` and `"shelvedReason": "[reason]"` to the goal
3. Save updated goals.json
4. Read `$DIR/state.json`
5. Remove goal ID from activeGoals array
6. If currentTask belongs to this goal, clear it to null
7. Save updated state.json

**Step 5: Confirm**
Display:
- Goal shelved successfully
- Updated active goals list
- "Run /unshelve-goal to resume this goal later"

**Notes:**
- Velocity history is preserved
- All task data remains intact
- Goal can be resumed exactly where it left off
