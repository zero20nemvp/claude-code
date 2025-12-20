---
description: "Execute current task with TDD discipline, tier-based quality, and verification. Usage: /do [--tier skimmed|semi|full]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---

You are executing a task with the full superpowers discipline: TDD, code review, verification.

## Directory Detection

Use `agentc/` as `$DIR`. Load `$DIR/agentc.json`.

## STEP 0: Verify Active Task

1. Check current.humanTask exists
2. If no task assigned: "No task assigned. Run /next first."
3. Load task details from humanTask
4. Check current.batchMode - if true, use batch execution flow

## STEP 0.1: Batch Mode Execution (If batchMode = true)

When batchMode is active, multiple tasks execute as a checklist:

1. Display batch header:
       === BATCH MODE ===
       Complete all items, code review runs once at end.

       □ [Task 1]
       □ [Task 2]
       □ [Task 3]

2. For each task in batch:
   - Mark as current focus
   - Execute (apply TDD if code task)
   - Mark complete: ✓ [Task 1]
   - Move to next

3. After ALL items complete:
   - Run code review ONCE (covers all changes)
   - Display summary

4. Output:
       BATCH COMPLETE [X items]

       ✓ [Task 1]
       ✓ [Task 2]
       ✓ [Task 3]

       DO: /done

**Batch mode skips per-item code review.** Review runs once at end.

**If batchMode = false:** Continue to normal single-task execution.

## STEP 0.25: Stage-Aware Execution

Check humanTask.type to determine execution path:

**type = "bootstrap" or "create-north-star":**

Run inline North Star creation:
1. Use AskUserQuestion: "What problem are you solving?"
2. Use AskUserQuestion: "Who has this problem most acutely?"
3. Use AskUserQuestion: "What does success look like?"
4. Create North Star from answers
5. Save to agentc.json
6. Output: "Created North Star: [name]" then DO: /done

**type = "create-goal":**

Run inline Goal creation:
1. Use AskUserQuestion: "What specific outcome do you want to achieve?"
2. Use AskUserQuestion: "How will you know it's done? (acceptance criteria)"
3. Use AskUserQuestion: "What might block you?"
4. Use AskUserQuestion: "When must this be complete?"
5. Create Goal with stage = "discovery", stageProgress all pending
6. Save to agentc.json
7. Output: "Created Goal: [wish]" then DO: /done

**type = "jtbd":**

Run inline JTBD discovery:
1. Load goal context
2. Use AskUserQuestion: "When [situation], I want to [motivation], so I can [outcome]"
3. Probe deeper with follow-up questions
4. Save JTBD to docs/jtbd/YYYY-MM-DD-[goal-slug].md
5. Update goal.stageProgress.jtbd = { status: "done", file: path }
6. Output: "JTBD documented" then DO: /done

**type = "stories":**

Run inline story mapping:
1. Load JTBD file from goal.stageProgress.jtbd.file
2. Convert jobs to user stories via AskUserQuestion for validation
3. Save to docs/stories/YYYY-MM-DD-[goal-slug].md
4. Update goal.stageProgress.stories = { status: "done", file: path }
5. Output: "Stories mapped" then DO: /done

**type = "features":**

Run inline feature writing:
1. Load stories file
2. Generate Gherkin feature files
3. Save to features/[goal-slug]/
4. Update goal.stageProgress.features = { status: "done", path: path }
5. Output: "Features written" then DO: /done

**type = "slices":**

Run inline vertical slicing:
1. Load feature files
2. Plan thin vertical slices via AskUserQuestion
3. Update goal.stageProgress.slices = { status: "done", branches: [...] }
4. Output: "Slices planned" then DO: /done

**type = null or "implementation":**

Continue to STEP 0.5 (normal TDD execution).

## STEP 0.5: Set Milk Quality Tier

Parse `--tier` argument if provided. Options: `skimmed`, `semi`, `full`

**Tier Selection:**
```
Argument: --tier [value]
Default: semi-skimmed
```

| Tier | Tests Required | Code Approach |
|------|----------------|---------------|
| **skimmed** | Happy case only | Bare minimum |
| **semi-skimmed** (default) | Happy + essential sad cases | Extensible, no overengineering |
| **full-phat** | Happy + all sad + essential mad + logging/monitoring | Production-ready |

Update `humanTask.milkQuality` in agentc.json:
```json
{
  "milkQuality": "[selected-tier]",
  "qualityVerification": {
    "happyCaseTested": false,
    "sadCasesTested": false,
    "madCasesTested": false,
    "loggingAdded": false,
    "monitoringAdded": false
  }
}
```

Display current tier:
```
=== Milk Quality: [TIER] ===
```

## STEP 0.6: Language Detection

Detect project language to apply appropriate tooling:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/detect-language.sh
```

**Set LANG_MODE based on result:**
- ruby - Use RSpec commands, Ruby examples, RBS type checking
- javascript - Use Jest/Vitest commands, TypeScript examples
- unknown - Use AskUserQuestion with options: ["Ruby/Rails", "JavaScript/TypeScript"]

**Update humanTask in agentc.json:**
```json
{
  "languageMode": "ruby|javascript"
}
```

**Display:**
```
=== Language Mode: [Ruby/Rails | JavaScript/TypeScript] ===
```

**Language-specific test commands:**

| Language | Test Command |
|----------|--------------|
| Ruby | `bundle exec rspec spec/path/to/spec.rb` |
| JavaScript | `npm test path/to/test.test.ts` |

## STEP 0.75: Auto-Detect Task Type & Apply Skills

**Analyze the task description to detect applicable skills:**

### Frontend Detection

Check if task involves ANY of:
- React, Vue, Svelte, Angular components
- HTML, CSS, SCSS, Tailwind
- UI elements (buttons, forms, cards, modals, menus)
- Pages (landing, dashboard, settings, profile)
- Styling, theming, design systems
- Animation, motion, transitions

**If frontend detected:**
```
=== Frontend Design Skill Activated ===

Detecting aesthetic requirements...
```

Apply the `frontend-design` skill:
1. **Pause before coding** - Choose aesthetic direction
2. **Document the design decision:**
   ```
   Aesthetic Direction: [chosen tone - e.g., "brutally minimal", "retro-futuristic"]
   Memorable Element: [the ONE thing someone will remember]
   Typography: [display font] / [body font]
   Palette: [primary] / [accent] / [background]
   ```
3. **Execute with the chosen direction** - all frontend code follows this vision
4. **Verify no AI slop** - no Inter/Roboto, no purple gradients on white

**Frontend tasks must pass the Frontend Design Checklist before /done.**

### Other Skill Detection

Similarly detect and apply:
- `systematic-debugging` - if task mentions bug, error, fix, investigate
- `brainstorming` - if task requires design decisions or architecture

## STEP 1: Start Timer and Update Loop State

Run the timer script to start tracking time.

Update agentc.json:
- Set current.loopState = "executing"
- Set current.lastAction = { action: "do", timestamp: now, description: "Started: [task]" }
- Set humanTask.status = "in_progress"
- Set humanTask.startedAt = now

## STEP 1.5: AI Does Max, Human Does Minimum

**Core principle: AI does everything it CAN. Human only does what ONLY human can do.**

Before executing, decompose the task:

1. Break task into subtasks
2. For each subtask ask: "Can AI do this?"
   - YES: AI executes immediately
   - NO: Queue for human (requires human capability)
3. Execute all AI subtasks first
4. Surface ONLY atomic human actions via AskUserQuestion

Human capabilities (only these require human):
- External system access (production credentials)
- Physical device testing
- Real browser sessions with auth
- Strategic authority / sign-off
- External communication (send emails, calls)
- Subjective UX judgment ("does this feel right?")
- Domain expertise not in codebase

Example:
- Task: "Send outreach to 3 founders"
- AI does: Draft messages, find contact info, format templates
- Human does: "Send this exact message to sarah@startup.io" [text provided]

The human receives the MINIMUM atomic action. AI handles everything else.

## STEP 2: Apply TDD Discipline (Tier-Based)

**For code tasks, follow RED-GREEN-REFACTOR with tier-appropriate test coverage:**

### Tier Requirements

**SKIMMED:** Happy case test only
- Write ONE test for the happy path
- Make it pass
- Done

**SEMI-SKIMMED:** Happy + essential sad cases
- Write happy case test FIRST
- Add essential sad case tests (e.g., null input, invalid data, auth failure)
- All tests must pass

**FULL PHAT:** Comprehensive + production-ready
- Happy case test FIRST
- Essential sad case tests
- Non-essential sad case tests (edge cases)
- Essential mad case tests (unexpected states, race conditions)
- Add logging to implementation
- Add monitoring hooks

### RED Phase (Write Failing Test)

1. **Write the test first** - before any implementation
2. **Run the test** - verify it FAILS
3. **Verify failure reason** - should fail for the RIGHT reason (not syntax error)

```
TDD RED: Writing failing test...
Milk Quality: [TIER]
Test file: [path]
Expected failure: [what should fail]

Running test...
Result: FAIL (expected) - [failure message]

Proceeding to GREEN phase.
```

**If test passes unexpectedly:** STOP. Investigate why. Don't proceed.

### GREEN Phase (Minimal Implementation)

1. **Write minimal code** to make test pass
2. **Run the test** - verify it PASSES
3. **No over-engineering** - just enough to pass

```
TDD GREEN: Implementing minimal code...
Implementation file: [path]

Running test...
Result: PASS

Test passes. Proceeding to REFACTOR phase.
```

### REFACTOR Phase (Clean Up)

1. **Improve code quality** while keeping tests green
2. **Run tests after each change** - stay green
3. **Commit when clean**

```
TDD REFACTOR: Cleaning up...
[Changes made]

Running tests...
Result: PASS (stayed green)

Committing: [commit message]
```

## STEP 3: Non-Code Tasks

For design/research/documentation tasks:
- TDD doesn't apply
- Focus on clear deliverables
- Document decisions made

```
Task type: [design/research/docs]
TDD: Not applicable

Executing task...
[Work done]

Deliverable: [what was produced]
```

## STEP 4: Dispatch Async Code Review

**After completing work, dispatch code-reviewer agent asynchronously:**

    Dispatching code review (async)...

Use the Task tool to dispatch the code-reviewer agent with run_in_background = true.

**Set reviewPending in state:**
    current.reviewPending = true

**Do NOT wait for review to complete.** Human can continue to verification.

Review will be checked in /done (STEP 2.5 Code Review Gate).

## STEP 5: Handle Immediate Critical Issues (If Review Completes Fast)

If review agent returns quickly with CRITICAL issues:

**CRITICAL issues:** Fix immediately
    CRITICAL: [issue]
    Fixing now...
    [Fix applied]
    Re-running tests...
    PASS

**IMPORTANT issues:** Note for /done gate
    IMPORTANT: [issue]
    Will address before /done.

**MINOR issues:** Log for future
    MINOR: [issue]
    Noted for future cleanup.

**If review still pending:** Continue to STEP 6. Review checked in /done.

## STEP 6: Verification Before Completion

**Run verification - must see actual output:**

1. **Run tests** - see actual PASS/FAIL output
2. **Check functionality** - verify it works
3. **Review changes** - git diff shows expected changes

```
=== Verification ===

Running tests...
[actual test output]
Result: X passed, 0 failed

Git status:
[files changed]

Verification: PASSED
```

**If verification fails:** Do NOT prompt for /done. Fix first.

## STEP 6.5: Tier Quality Gate

**Verify tier requirements met before allowing completion:**

### SKIMMED Checklist
- [ ] Happy case test written FIRST
- [ ] Happy case test passes

### SEMI-SKIMMED Checklist
- [ ] Happy case test written FIRST
- [ ] Essential sad case tests written (at least 1-2)
- [ ] All tests pass

### FULL PHAT Checklist
- [ ] Happy case test written FIRST
- [ ] Essential sad case tests written
- [ ] Non-essential sad case tests written
- [ ] Essential mad case tests written (at least 1)
- [ ] Logging implemented in code
- [ ] Monitoring hooks added

**Update qualityVerification in agentc.json:**
```json
{
  "qualityVerification": {
    "happyCaseTested": true,
    "sadCasesTested": true,    // semi-skimmed, full-phat only
    "madCasesTested": true,    // full-phat only
    "loggingAdded": true,      // full-phat only
    "monitoringAdded": true    // full-phat only
  }
}
```

**Display tier gate result:**
```
=== Milk Quality Gate: [TIER] ===
✓ Happy case tested
✓ Sad cases tested (if required)
✓ Mad cases tested (if required)
✓ Logging added (if required)
✓ Monitoring added (if required)

Tier Requirements: PASSED
```

**If tier requirements NOT met:** Do NOT prompt for /done. Fix first. This is STRICT enforcement.

## STEP 6.75: Frontend Design Gate (If Applicable)

**Only for tasks where frontend-design skill was activated.**

### Frontend Design Checklist

- [ ] Aesthetic direction was chosen and documented
- [ ] Typography is distinctive (NOT Inter, Roboto, Arial, system fonts)
- [ ] Color palette is cohesive and intentional
- [ ] At least one memorable visual element exists
- [ ] Motion/animation adds polish (not required, but encouraged)
- [ ] No generic "AI slop" patterns detected
- [ ] Responsive behavior verified (if applicable)
- [ ] Accessibility basics checked (if applicable)

**Display frontend gate result:**
```
=== Frontend Design Gate ===
Aesthetic: [chosen direction]
Typography: ✓ Distinctive ([font names])
Palette: ✓ Cohesive ([colors])
Memorable: ✓ [the one thing]
AI Slop Check: ✓ None detected

Frontend Requirements: PASSED
```

**AI Slop Detection - FAIL if any found:**
- Inter, Roboto, Arial as primary font
- Purple/blue gradient on white background
- Generic card layouts with no personality
- No animation or visual interest
- Cookie-cutter component styling

**If frontend requirements NOT met:** Do NOT prompt for /done. Redesign first.

## STEP 7: Prompt for Completion

Only after:
- TDD cycle complete (for code tasks)
- Code review passed (critical/important fixed)
- Verification passed
- Tier quality gate passed
- Frontend design gate passed (if frontend task)

Output (minimal):

    COMPLETE
    [Task description]

    DO: /done

That's it. No verbose summary. Human trusts the process passed all gates.

## Key Principles

**TDD is mandatory for code tasks:**
- Test FIRST, see it FAIL
- Implement MINIMAL code to pass
- Refactor while staying GREEN

**Milk Quality tiers calibrate effort:**
- Skimmed: Happy case only, bare minimum
- Semi-skimmed: Happy + essential sad cases (default)
- Full phat: Comprehensive, production-ready
- Tier gate is STRICTLY enforced

**Code review is async:**
- Dispatched after work, doesn't block /do
- Checked in /done gate
- CRITICAL issues: warn, allow --force (logs to reviewDebt)
- Human maintains flow state

**Verification is required:**
- Must see actual test output
- "Should work" is not acceptable
- Evidence before completion claims

**Never skip the discipline:**
- These rules exist because they work
- Shortcuts lead to bugs
- Process IS the productivity
