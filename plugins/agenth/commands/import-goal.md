You are importing a goal from a WOOP-format JSON file.

**Expected Input Format:**
The user should provide a JSON file path or JSON object with these fields:
```json
{
  "wish": "What you want to achieve",
  "current_state": [
    "Statement describing where you are now",
    "Another aspect of current reality",
    "Third current state item"
  ],
  "done_when": [
    "First acceptance criterion",
    "Second acceptance criterion",
    "Third acceptance criterion"
  ],
  "obstacles": ["Internal blocks", "Procrastination", "Self-doubt"],
  "plan": "High-level approach or key milestones",
  "deadline": "2025-11-15T23:59:59"
}
```

**Optional fields:**
- `name`: Short goal name (if not provided, generate from wish)
- `current_state`: If not provided, use ["Not started yet"]

**Processing Steps:**

**Step 1: Parse Input**
1. Ask user for the JSON file path or have them paste the JSON
2. Read and parse the JSON
3. Validate required fields: wish, done_when (must be array), deadline
4. Generate name from wish if not provided
5. Set current_state to ["Not started yet"] if not provided (must be array)

**Step 2: Generate Goal Structure**
1. Read `$DIR/goals.json` to get next goal ID
2. Generate unique goal ID (goal-XXX format)
3. Reverse-engineer 3-4 milestones bridging current_state → done_when criteria (each milestone moves you from current reality toward acceptance criteria)
4. Break down into independent tasks between milestones (3-5 tasks per milestone)
5. Estimate points (1,2,3,5,8) and blocks for each task
6. Assign energy levels ("in" or "out") to each task
7. Create if-then contingency rules from obstacles

**Step 3: Present FULL PLAN for Approval**
Show the human:
- WOOP summary (wish, current_state, done_when acceptance criteria, obstacles)
- All milestones in order with task breakdowns
- Point and block estimates for each task
- Total estimated effort (sum of points and blocks)
- Projected completion timeline based on current velocity from `$DIR/velocity.json`
- If-then contingency rules for each obstacle

**Step 4: Wait for Approval**
Human can:
- Accept (proceed to save)
- Modify milestones/tasks (iterate on plan)
- Reject (cancel import)

**Step 5: Save Plan**
1. Create `$DIR/plans/` directory if it doesn't exist
2. Save original WOOP input to `$DIR/plans/goal-{id}-woop.json`
3. Save generated plan to `$DIR/plans/goal-{id}-original.json`
4. Add the goal object to `$DIR/goals.json` array
5. Update `$DIR/state.json` to include goal ID in activeGoals array
6. Confirm import successful

**Error Handling:**
- If JSON is invalid, show clear error message
- If required fields missing, prompt for them
- If deadline format is wrong, ask for ISO format: YYYY-MM-DDTHH:MM:SS
