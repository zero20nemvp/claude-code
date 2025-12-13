---
description: "Add a new goal with brainstorming - Socratic design refinement"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

You are adding a new GOAL to the AgentC system using the brainstorming methodology.

**Goals are ongoing directions you move toward - they never "complete".**

## Directory Detection

Check if `agentc/` exists in project root. If not, create it.
Use `agentc/` as `$DIR` for all file paths.

## STEP 0: Check Active Goal Limit

1. Load `$DIR/agentc.json` (create if doesn't exist with empty structure)
2. Count goals where `status === "active"`
3. **If activeGoals >= 3:**
   - Display: "You have 3 active goals (maximum). To add a new goal, shelve one first."
   - Show current active goals
   - Offer to shelve one now or abort
4. **Otherwise:** Proceed to brainstorming

## STEP 1: Brainstorming Phase

**Announce:** "I'm using brainstorming to help refine your goal."

**Understanding the idea:**
- Check out the current project state first (files, docs, recent commits)
- Ask questions one at a time to refine the goal
- Prefer multiple choice questions when possible
- Only one question per message

**Questions to explore (one at a time):**
1. What direction are you trying to move toward? (open-ended)
2. What's the current state? Where are you now?
3. What type of goal is this? (construction, feature, quality, infrastructure, deployment, architecture, performance, security, automation, dx)
4. What would success look like? (helps clarify direction)

**Exploring approaches:**
- If the direction is unclear, propose 2-3 different framings
- Present options conversationally with your recommendation
- Lead with your recommended framing and explain why

**Presenting the design:**
- Once you understand the goal, present it for validation
- Ask: "Does this capture what you're aiming for?"

## STEP 2: Create Goal Object

After brainstorming validation, create:

```json
{
  "id": "g[next-number]",
  "name": "[short name]",
  "direction": "[ongoing aspiration - never completes]",
  "design": {
    "decisions": ["key design decisions from brainstorming"],
    "brainstormedAt": "[ISO timestamp]"
  },
  "status": "active",
  "frontOfMind": false
}
```

## STEP 3: Save Goal

1. Load existing `$DIR/agentc.json` or create:
   ```json
   {
     "version": "1.0",
     "goals": [],
     "intents": [],
     "current": {"humanTask": null, "aiTasks": [], "lastCheckIn": null},
     "velocity": {"totalPoints": 0, "totalBlocks": 0, "history": []},
     "journal": []
   }
   ```
2. Generate unique goal ID (g1, g2, g3...)
3. Append new goal to goals array
4. Write back to `$DIR/agentc.json`

## STEP 4: Confirm and Suggest Intent

```
Goal added: [id] "[name]"
Direction: [direction]

Design decisions captured:
- [decision 1]
- [decision 2]

Goals are ongoing directions. To make progress, create an intent:

Run /add-intent [goal-id] to create your first commitment
```

## Key Principles

- **One question at a time** - Don't overwhelm
- **Multiple choice preferred** - Easier to answer
- **YAGNI ruthlessly** - Keep goals focused
- **Explore alternatives** - Propose 2-3 framings if unclear
- **Validate incrementally** - Confirm understanding before saving
