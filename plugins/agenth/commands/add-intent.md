---
description: "Add a new intent (WOOP commitment) for a construction goal"
arguments:
  - name: goal-id
    description: "The goal ID to add an intent for (e.g., goal-001)"
    required: false
---

You are adding a new INTENT to the AgentH system.

**Intents are concrete WOOP commitments with acceptance criteria.**
They belong to a goal (ongoing direction) and "complete" when acceptance criteria are met.

Examples:
- Goal: "Codebase should be maintainable" → Intent: "Add test coverage to auth module"
- Goal: "Ship reliable software" → Intent: "Set up CI/CD pipeline"

**Step 0: Identify Target Goal**
1. If goal-id provided: Validate it exists in `${AGENTH_DATA_DIR}/goals.json`
2. If no goal-id provided:
   - Load goals.json and show active goals
   - Ask user which goal this intent is for
3. **Check for existing active intent:**
   - Load `${AGENTH_DATA_DIR}/intents.json` (create if doesn't exist)
   - If goal already has an active intent: Warn user

**Step 1: Analyze Codebase First**
Before gathering WOOP information:
- Check for `stack.md` in project root
- Analyze current codebase state
- Understand what's implemented vs missing
- This grounds the intent in reality

**Step 2: Gather WOOP Information**
Use AskUserQuestion tool to prompt for:
1. **Wish**: What specific outcome do you want to achieve?
2. **Outcome**: What are the acceptance criteria? (array of "done when" statements)
3. **Obstacles**: What blocks might prevent success? (technical debt, complexity, time)
4. **Plan**: If-then contingency rules for each obstacle
5. **Deadline**: When must this be complete?

**Step 3: Create Milestone Plan**
Reverse-engineer milestones from current codebase state → outcome:
- Each milestone represents a meaningful state transition
- Bridge the gap between where the code is and where it needs to be
- Typically 2-4 milestones per intent
- Consider AI-automatable vs human-required work

**Step 4: Present INTENT PLAN for Approval**
Show the human:
```
INTENT for: goal-xxx "[goal name]"

Wish: [wish]

Outcome (acceptance criteria):
- [criterion 1]
- [criterion 2]

Obstacles:
- [obstacle 1]

If-Then Rules:
- If [obstacle], then [action]

Milestones:
1. [Milestone name] - [acceptance criteria]
   AI can: [automatable work]
   Human needs: [judgment/creative work]

Deadline: [date] ([Y days from now])
Estimated Effort: ~X blocks

Approve this intent?
```

**Step 5: Save Intent**
1. Create `${AGENTH_DATA_DIR}/intents.json` if it doesn't exist
2. Generate unique intent ID
3. Add the intent object with all WOOP data
4. Update state if needed

**Step 6: Confirm**
```
Intent added: [intent-id] "[wish]"
For goal: [goal-id] "[goal direction]"
Deadline: [date]

Run /next to start working on this intent.
```

**IMPORTANT:**
- Only ONE active intent per goal at a time
- Intents COMPLETE when all outcome criteria are met
- When intent completes, goal's current_state updates automatically
- AI agents can work on automatable parts while human handles judgment work
