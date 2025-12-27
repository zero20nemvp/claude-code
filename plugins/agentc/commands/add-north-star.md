---
description: "Add a new North Star with Socratic questioning - unearth your guiding direction"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

You are adding a new NORTH STAR to the AgentC system.

**North Stars are guiding directions you navigate toward - they never "complete".**

## File Locking (Multi-Process Safety)

Before accessing agentc.json, acquire the lock:
```bash
scripts/lock.sh lock agentc/agentc.json
```

**CRITICAL:** Release the lock before completing this command:
```bash
scripts/lock.sh unlock agentc/agentc.json
```

If lock fails: "Another AgentC session may be active."

## Directory Detection

Check if `agentc/` exists in project root. If not, create it.
Use `agentc/` as `$DIR` for all file paths.

## STEP 0: Load & Migrate Data

1. Load `$DIR/agentc.json` (create if doesn't exist with empty structure)
2. **AUTO-MIGRATION:** If old schema detected, migrate:
   - If `goals[]` exists but `northStars[]` doesn't: rename `goals` → `northStars`
   - If `intents[]` exists but `goals[]` doesn't (after migration): rename `intents` → `goals`
   - Update all `goalId` references to `northStarId` in goals array
   - Save migrated structure
   - Announce: "Migrated data schema: goals → northStars, intents → goals"

## STEP 1: Check Active North Star Limit

1. Count north stars where `status === "active"`
2. **If activeNorthStars >= 3:**
   - Display: "You have 3 active North Stars (maximum). To add a new one, shelve one first."
   - Show current active north stars
   - Offer to shelve one now or abort
3. **Otherwise:** Proceed to questioning

## STEP 2: Detect Context

**Check for existing code:**
- Scan for source files (*.js, *.ts, *.py, *.go, etc.)
- Check for package.json, requirements.txt, go.mod, etc.

**If existing code found:** Flow = "constraint-first"
**If greenfield:** Ask user which framing:

```
Starting fresh. Which angle helps you think about this?

a) Problem-first - "What's broken or missing?"
b) Future-first - "What does success look like?"
```

## STEP 3: Socratic Questioning

**Ask ONE question at a time. Keep probing each angle until user signals "enough" or moves on.**

### Problem-First Flow (greenfield option a)
1. **Problem** → 2. **Future** → 3. **Constraint** → 4. **Scope** (if fuzzy)

### Future-First Flow (greenfield option b)
1. **Future** → 2. **Problem** → 3. **Constraint** → 4. **Scope** (if fuzzy)

### Constraint-First Flow (existing code)
1. **Constraint** → 2. **Problem** → 3. **Future** → 4. **Scope** (if fuzzy)

---

### Problem Angle
**Opening:** "What's broken or missing right now?"

**Follow-ups (until user signals done):**
- "What makes that painful?"
- "How is that showing up day-to-day?"
- "What have you tried?"

### Future Angle
**Opening:** "What does the future look like when this is working?"

**Follow-ups (until user signals done):**
- "What becomes possible then?"
- "How would you know you're there?"
- "What changes for you?"

### Constraint Angle
**Opening:** "What's the one thing that matters most right now?"

**Follow-ups (until user signals done):**
- "Why that over everything else?"
- "What happens if you ignore it?"
- "What's blocking it currently?"

### Scope Angle (only if direction feels fuzzy after main angles)
**Opening:** "What's explicitly NOT part of this?"

**Follow-ups:**
- "Anything you're tempted to include but shouldn't?"
- "What would be scope creep?"

---

## STEP 4: Synthesize North Star

After questioning, synthesize and present:

```
Here's what I heard:

**Name:** [punchy 2-4 word name]

**Direction:** [one sentence - where you're headed]

**Why:** [motivation behind this direction]

**Not:** [explicit exclusions, if any were discussed]

Does this capture your North Star?
```

**If user wants changes:** Iterate until they confirm.

## STEP 5: Create North Star Object

After validation, create:

```json
{
  "id": "ns[next-number]",
  "name": "[punchy name]",
  "direction": "[ongoing aspiration - never completes]",
  "why": "[motivation]",
  "not": ["explicit exclusion 1", "explicit exclusion 2"],
  "design": {
    "questioningFlow": "[problem-first|future-first|constraint-first]",
    "brainstormedAt": "[ISO timestamp]"
  },
  "status": "active",
  "frontOfMind": false
}
```

## STEP 6: Save North Star

1. Load existing `$DIR/agentc.json` or create:
   ```json
   {
     "version": "1.1",
     "northStars": [],
     "goals": [],
     "current": {"humanTask": null, "aiTasks": [], "lastCheckIn": null},
     "velocity": {"totalPoints": 0, "totalBlocks": 0, "history": []},
     "journal": [],
     "suggestedCapabilities": []
   }
   ```
2. Generate unique ID (ns1, ns2, ns3...)
3. Append new north star to northStars array
4. Write back to `$DIR/agentc.json`

## STEP 7: Confirm and Suggest Goal

```
North Star added: [id] "[name]"

Direction: [direction]
Why: [why]
Not: [exclusions or "No explicit exclusions"]

North Stars are guiding directions. To make tangible progress, create a goal:

Run /add-goal [north-star-id] to create your first achievable objective
```

## Key Principles

- **One question at a time** - Don't overwhelm
- **User controls depth** - Keep probing until they signal done
- **Context-aware flow** - Existing code = constraint-first
- **Scope only if fuzzy** - Skip boundaries if direction is tight
- **Validate incrementally** - Confirm understanding before saving
