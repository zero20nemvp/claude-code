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

1. Check `current.humanTask` exists
2. If no task assigned: "No task assigned. Run /next first."
3. Load task details from humanTask

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

## STEP 1: Start Timer

Run the timer script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/timer.sh start
```

Update humanTask.status to "in_progress" and set startedAt timestamp.

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

## STEP 4: Automatic Code Review

**After completing work, dispatch code-reviewer agent:**

```
Dispatching code review...
```

Use the Task tool to dispatch the code-reviewer agent:

```
Review the code changes just made for this task:
- Task: [task description]
- Files changed: [list]
- Approach: [brief description]

Check for:
- Bugs or logic errors
- Security vulnerabilities
- Code quality issues
- Test coverage gaps
- Adherence to project conventions

Report findings with severity: CRITICAL, IMPORTANT, or MINOR.
```

## STEP 5: Handle Review Findings

**CRITICAL issues:** Must fix before proceeding
```
CRITICAL: [issue]
Fixing now...
[Fix applied]
Re-running tests...
PASS
```

**IMPORTANT issues:** Fix before /done
```
IMPORTANT: [issue]
Fixing now...
[Fix applied]
```

**MINOR issues:** Note for future
```
MINOR: [issue]
Noted for future cleanup.
```

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

## STEP 7: Prompt for Completion

Only after:
- TDD cycle complete (for code tasks)
- Code review passed (critical/important fixed)
- Verification passed
- **Tier quality gate passed**

```
=== Task Complete ===

Task: [description]
Milk Quality: [TIER]
TDD: RED → GREEN → REFACTOR
Code Review: PASSED (X issues fixed)
Verification: PASSED
Tier Gate: PASSED

Ready to record completion.
Run /done to finish and get next task.
```

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

**Code review is automatic:**
- Runs after every /do completion
- Critical issues block completion
- Important issues fixed before /done

**Verification is required:**
- Must see actual test output
- "Should work" is not acceptable
- Evidence before completion claims

**Never skip the discipline:**
- These rules exist because they work
- Shortcuts lead to bugs
- Process IS the productivity
