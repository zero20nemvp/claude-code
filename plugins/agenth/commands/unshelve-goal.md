---
description: Resume a shelved/paused goal and add it back to active task selection
---

You are unshelving (resuming) a goal in the AgentH system.

**Step 1: Show Shelved Goals**
Read `$DIR/goals.json` and display all goals with `"status": "shelved"`:
- Goal ID and name
- Progress when shelved (points completed / total points)
- When it was shelved (shelvedAt timestamp)
- Why it was shelved (shelvedReason)
- Original deadline

**Step 2: Get User Selection**
Ask which goal to unshelve (by ID or number selection).

**Step 3: Confirm Unshelving**
Ask:
- "Do you want to keep the original deadline or set a new one?"
- If new deadline, get the new date

**Step 4: Update Data**
1. Read `$DIR/goals.json`
2. Remove `"status": "shelved"`, `"shelvedAt"`, and `"shelvedReason"` fields
3. Update deadline if user provided new one
4. Save updated goals.json
5. Read `$DIR/state.json`
6. Add goal ID back to activeGoals array
7. Save updated state.json

**Step 5: Confirm**
Display:
- Goal unshelved successfully
- Updated active goals list
- Remaining work (points/blocks)
- "Run /next to get your next task"

**Notes:**
- All progress and velocity data is preserved
- Tasks resume exactly where they left off
- Goal will now appear in /next task selection based on deadline priority
