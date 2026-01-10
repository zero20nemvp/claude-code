---
name: create
description: "Create north star or goal. Usage: /create north-star OR /create goal [ns-id]"
arguments:
  - name: type
    description: "north-star or goal"
    required: true
  - name: target
    description: "For goal: north-star-id (e.g., ns1)"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

You are creating AgentC structures. Route based on type argument.

## Setup

Check if `agentc/` exists. Create if not.
Load `agentc/agentc.json` (create empty structure if doesn't exist).

## Auto-Migration

If old schema detected:
- `goals[]` without `northStars[]` → rename `goals` → `northStars`
- `intents[]` → rename to `goals`
- Save and announce migration

## Route by Type

**`/create north-star`** → North Star creation flow
**`/create goal [ns-id]`** → Goal creation flow

---

# NORTH STAR CREATION

North Stars are guiding directions - they never "complete."

## Step 1: Check Limit

Count active north stars. If >= 3:
- Show current active north stars
- Offer to shelve one or abort
- Max 3 active at once

## Step 2: Detect Context

**If source files exist:** Flow = constraint-first
**If greenfield:** Ask user:
```
Starting fresh. Which angle?
a) Problem-first - "What's broken or missing?"
b) Future-first - "What does success look like?"
```

## Step 3: Socratic Questioning

**Ask ONE question at a time. Keep probing until user signals done.**

### Problem-First Flow
1. Problem → 2. Future → 3. Constraint → 4. Scope (if fuzzy)

### Future-First Flow
1. Future → 2. Problem → 3. Constraint → 4. Scope (if fuzzy)

### Constraint-First Flow (existing code)
1. Constraint → 2. Problem → 3. Future → 4. Scope (if fuzzy)

**Questions by angle:**

| Angle | Opening | Follow-ups |
|-------|---------|------------|
| Problem | "What's broken or missing?" | "What makes that painful?" "How is it showing up?" |
| Future | "What does the future look like when this works?" | "What becomes possible?" "How would you know?" |
| Constraint | "What's the one thing that matters most?" | "Why that over everything?" "What's blocking it?" |
| Scope | "What's explicitly NOT part of this?" | "Anything tempting but shouldn't include?" |

## Step 4: Synthesize

```
Here's what I heard:

**Name:** [2-4 word name]
**Direction:** [one sentence]
**Why:** [motivation]
**Not:** [exclusions]

Does this capture your North Star?
```

Iterate until confirmed.

## Step 5: Save North Star

```json
{
  "id": "ns[next]",
  "name": "[name]",
  "direction": "[direction]",
  "why": "[why]",
  "not": ["exclusion 1"],
  "design": {
    "questioningFlow": "[flow-type]",
    "brainstormedAt": "[ISO timestamp]"
  },
  "status": "active",
  "frontOfMind": false
}
```

## Step 6: Confirm

```
North Star added: [id] "[name]"

Direction: [direction]
Why: [why]

Create a goal: /create goal [id]

DO: /create goal [id]
```

---

# GOAL CREATION

Goals are concrete WOOP commitments with milestones.

## Step 1: Identify North Star

**If target provided:** Validate ns-id exists
**If no target:** Show active north stars, ask which one

Check: Only ONE active goal per north star

## Step 2: Analyze Codebase

Before gathering WOOP:
- Check for `stack.md`
- Analyze current codebase state
- Ground the goal in reality

Announce: "Analyzing codebase to ground this goal."

## Step 3: Gather WOOP (one question at a time)

| Element | Question |
|---------|----------|
| **Wish** | What specific outcome do you want? |
| **Outcome** | What are the acceptance criteria? (done when...) |
| **Obstacles** | What might block success? |
| **Plan** | If [obstacle], then [action]? |
| **Deadline** | When must this be complete? |

## Step 4: Create Milestones (NOT Tasks)

From current state → outcome, identify 2-4 milestones:

```json
{
  "id": "m1",
  "name": "Auth infrastructure",
  "description": "User model, JWT, middleware",
  "acceptance_criteria": ["User model exists", "JWT works"],
  "status": "pending",
  "progress": 0
}
```

**Tasks are NOT pre-planned.** `/next` generates them dynamically.

## Step 5: Present for Approval

```
GOAL for: [ns-id] "[north star]"

Wish: [wish]

Outcome:
- [criterion 1]
- [criterion 2]

Obstacles: [obstacles]

If-Then: If [obstacle], then [action]

Milestones:
1. [m1] [name]
2. [m2] [name]

Deadline: [date]

Approve?
```

## Step 6: Save Goal

```json
{
  "id": "g[next]",
  "northStarId": "[ns-id]",
  "wish": "[wish]",
  "outcome": ["criterion 1"],
  "obstacles": ["obstacle 1"],
  "ifThen": [{"if": "...", "then": "..."}],
  "milestones": [...],
  "deadline": "[ISO]",
  "status": "active",
  "created": "[ISO]"
}
```

## Step 7: Confirm

```
Goal added: [id] "[wish]"
For: [ns-id] "[north star]"

Milestones: [count]
Deadline: [date]

DO: /next
```

---

## Key Principles

- **One question at a time** - Don't overwhelm
- **Ground in reality** - Analyze codebase first
- **Milestones not tasks** - /next generates tasks dynamically
- **WOOP methodology** - Wish, Outcome, Obstacles, Plan
- **Max 3 active north stars**
- **One active goal per north star**
