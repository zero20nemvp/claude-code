You are adding a new goal to the AgentH system using MILESTONE-BASED PLANNING (no pre-planned tasks).

**Step 0: Check Active Goal Limit**
1. Load `$DIR/state.json` and count activeGoals.length
2. **If activeGoals.length >= 3:**
   - Display: "⚠️ You have 3 active goals (maximum). To add a new goal, shelve one first using `/shelve-goal`"
   - Load goals.json and show current active goals:
     ```
     Current active goals:
     - [ACTIVE] goal-xxx: [Goal Name] (deadline: [date])
     - [ACTIVE] goal-yyy: [Goal Name] (deadline: [date])
     - [ACTIVE] goal-zzz: [Goal Name] (deadline: [date])
     ```
   - Offer: "Would you like to shelve a goal now to make room?"
   - If yes: Run inline shelve workflow (ask which goal, get reason, shelve it)
   - If no: Abort goal creation with message "Run `/shelve-goal [id]` when ready, then try `/add-goal` again"
3. **Otherwise (< 3 active goals):** Proceed to Step 1

**Step 1: Gather WOOP Information**
Use AskUserQuestion tool to prompt for:
1. **Wish**: What do you want to achieve?
2. **Current State**: Where are you now? (array of statements describing current reality)
3. **Done When**: What are the acceptance criteria? (array of "we are done when..." statements)
4. **Obstacles**: What internal blocks might prevent success? (procrastination, doubt, habits)
5. **Deadline**: When must this be complete?

**Step 2: Create Milestone Plan**
1. Read `$DIR/goals.json` to check existing goals
2. Generate a unique goal ID (e.g., "goal-003")
3. **Reverse-engineer milestone checkpoints** from current_state → done_when criteria
   - Each milestone represents a meaningful state transition
   - Bridge the gap between where they are and where they want to be
   - Typically 3-5 milestones per goal
4. For each milestone, define:
   - id, name, description
   - **acceptance_criteria**: array of specific, measurable criteria (what must be true to consider this milestone done)
   - status: "pending"
   - progress: 0
5. Create **if-then rules** for each obstacle:
   - condition: when obstacle manifests
   - action: specific response/mitigation

**Step 3: Estimate Total Effort**
Make a rough estimate of total blocks needed for the entire goal:
- Consider complexity of each milestone
- Use velocity data if available (from velocity.json)
- This is just for deadline feasibility check, not task-level planning

**Step 4: Present MILESTONE PLAN for Approval**
Show the human:
```
Goal: [Wish]

Milestones:
1. [Milestone Name]
   Bridge: [description]
   Acceptance Criteria:
   - [criterion 1]
   - [criterion 2]
   ...

2. [Milestone Name]
   ...

If-Then Rules:
- If [obstacle], then [action]

Estimated Total Effort: ~X blocks
Deadline: [date] ([Y days from now])
Feasibility: [On track / Tight / Unrealistic]
```

**Step 5: Wait for Approval**
Human can:
- Accept (proceed to save)
- Modify milestones/criteria (iterate on plan)
- Reject (cancel)

**Step 6: Save Goal**
1. Create `$DIR/plans/` directory if it doesn't exist
2. Save WOOP plan to `$DIR/plans/goal-{id}-woop.json`
3. Add the goal object to `$DIR/goals.json` with structure:
   ```json
   {
     "id": "goal-xxx",
     "name": "[name]",
     "frontOfMind": false,
     "wish": "[wish]",
     "current_state": [...],
     "done_when": [...],
     "obstacles": [...],
     "milestones": [...],
     "ifThenRules": [...],
     "deadline": "[ISO date]",
     "created": "[ISO date]",
     "status": "active"
   }
   ```
4. Update `$DIR/state.json` to include this goal in activeGoals

Confirm goal added successfully.

**IMPORTANT: Do NOT pre-plan tasks. Tasks will be generated dynamically by /next based on milestone acceptance criteria.**
