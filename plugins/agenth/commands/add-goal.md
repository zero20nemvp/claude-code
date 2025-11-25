You are adding a new GOAL to the AgentH system.

**Goals are ongoing directions you move toward - they never "complete".**
WOOP commitments go in intents (run /add-intent after creating a goal).

Examples:
- "Codebase should be maintainable" (ongoing direction)
- "Ship reliable software" (ongoing aspiration)
- "Have comprehensive test coverage" (continuous goal)

## Directory Detection

Check if `agenth/` exists, else check `agentme/`. Use as `$DIR`.

## Step 0: Check Active Goal Limit

1. Load `$DIR/goals.json` and count goals where `status === "active"`
2. **If activeGoals >= 3:**
   - Display: "You have 3 active goals (maximum). To add a new goal, shelve one first using `/shelve-goal`"
   - Show current active goals
   - Offer to shelve one now or abort
3. **Otherwise:** Proceed to Step 1

## Step 1: Gather Minimal Goal Information

Use AskUserQuestion tool to prompt for:
1. **Name**: Short name for the goal (e.g., "Maintainable codebase")
2. **Direction**: What ongoing aspiration? (e.g., "Toward code that's easy to change and understand")
3. **Current State**: Where are you now? (array of statements describing current reality)
4. **Goal Type** (optional): construction, feature, quality, infrastructure, deployment, architecture, performance, security, automation, dx

**DO NOT collect:** wish, done_when, obstacles, milestones, ifThenRules, deadline
These belong to intents, not goals.

## Step 2: Create Goal Object

```json
{
  "id": "goal-XXX",
  "name": "[name]",
  "direction": "[direction]",
  "current_state": [...],
  "goalType": "[type or 'construction']",
  "frontOfMind": false,
  "status": "active"
}
```

## Step 3: Save Goal

1. Read existing `$DIR/goals.json`
2. Generate unique goal ID (highest existing + 1)
3. Append new goal to array
4. Write back to `$DIR/goals.json`
5. Update `$DIR/state.json` activeGoals array

## Step 4: Confirm and Suggest Intent

```
Goal added: goal-XXX "[name]"
Direction: [direction]
Current state: [current_state summary]

Goals are ongoing directions. To make progress, create an intent:

Run /add-intent goal-XXX to create your first commitment
```

**Key Principles:**
- Goals are minimal (direction + current_state only)
- Goals never complete - you move toward them
- WOOP methodology goes in intents
- Milestones and deadlines belong to intents
- One active intent per goal at a time
