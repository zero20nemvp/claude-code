---
name: assess
description: "Assess goal quality and autonomy readiness before autonomous execution"
arguments:
  - name: goal-id
    description: "Specific goal ID to assess (e.g., g1). If omitted, assesses all goals."
    required: false
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
---

You are assessing goal quality to determine autonomy readiness. High-quality goals with testable acceptance criteria enable effective autonomous execution. Vague goals lead to wasted effort.

## STEP 1: Load State

Load `agentc/agentc.json` and extract:
- All north stars and their goals
- If goal-id argument provided, focus on that specific goal
- All acceptance criteria for each goal's milestones

## STEP 2: Define Quality Criteria

Each acceptance criterion is scored on 4 dimensions:

| Criterion | Question | Pass Example | Fail Example |
|-----------|----------|--------------|--------------|
| **Testable** | Can it be verified programmatically? | "User can log in" | "Login feels good" |
| **Specific** | Is the language unambiguous? | "Shows error message" | "Handles errors properly" |
| **Measurable** | Is there a clear pass/fail condition? | "Loads in < 2s" | "Loads quickly" |
| **Independent** | Can it be verified without human judgment? | "Returns 200 status" | "UX feels right" |

## STEP 3: Analyze Each Goal

For each goal (or the specified goal):

### 3.1 Extract Acceptance Criteria

From each milestone, extract the acceptance criteria.

### 3.2 Score Each Criterion

For each acceptance criterion:

1. **Testable**: Can this be verified by code/tests?
   - ✅ Yes: "User model has email field", "API returns JSON"
   - ❌ No: "System works well", "Code is clean"

2. **Specific**: Is the language precise?
   - ✅ Yes: "Password must be 8+ characters", "Shows 'Invalid email' error"
   - ❌ No: "Validates properly", "Errors handled"

3. **Measurable**: Is there a clear pass/fail?
   - ✅ Yes: "Response time < 500ms", "All tests pass"
   - ❌ No: "Fast enough", "Good performance"

4. **Independent**: Can Claude verify without asking human?
   - ✅ Yes: "Returns HTTP 200", "Creates database record"
   - ❌ No: "Looks good", "Feels intuitive", "Users like it"

### 3.3 Calculate Score

- Each criterion: 0-4 points (one for each dimension)
- Goal score: Sum of all criterion scores / (4 * number of criteria) * 100%

### 3.4 Generate Suggestions

For each failing dimension, suggest a concrete improvement:

**Bad → Good examples:**
- "Works well" → "All test cases pass"
- "Fast" → "Responds in < 200ms"
- "Handles errors" → "Invalid input returns 400 with error message"
- "Good UX" → "Form shows inline validation errors"

## STEP 4: Determine Readiness Level

| Score | Level | Action |
|-------|-------|--------|
| < 50% | 🔴 NOT READY | Block autonomous execution |
| 50-75% | 🟡 NEEDS WORK | Warn, allow with confirmation |
| > 75% | 🟢 READY | Proceed automatically |

## STEP 5: Output Report

### If assessing all goals:

```
=== NORTH STAR QUALITY REPORT ===

ns1: "[North Star Name]"
  └─ g1: "[Goal Name]" - 75% ready 🟢 (1 criterion needs work)
  └─ g2: "[Goal Name]" - 100% ready 🟢 ✓
  └─ g3: "[Goal Name]" - 50% ready 🟡 (2 criteria need work)

ns2: "[North Star Name]"
  └─ g1: "[Goal Name]" - 25% ready 🔴 (3 criteria need work)
  └─ g2: "[Goal Name]" - 100% ready 🟢 ✓

RECOMMENDATIONS:
  1. Fix g3 on ns1 before autonomous execution
  2. 🔴 g1 on ns2 requires significant clarification

Run /assess [goal-id] for detailed breakdown
```

### If assessing specific goal:

```
=== GOAL QUALITY ASSESSMENT ===

Goal: "[Goal Name]" (g1)
North Star: "[North Star Name]" (ns1)

ACCEPTANCE CRITERIA ANALYSIS:

  1. "User can log in with valid credentials"
     ✅ Testable  ✅ Specific  ✅ Measurable  ✅ Independent
     Score: 4/4 ✓

  2. "Login should feel fast"
     ❌ Testable  ❌ Specific  ❌ Measurable  ❌ Independent
     Score: 0/4
     Suggestion: "Login completes in < 500ms"

  3. "Errors are handled properly"
     ✅ Testable  ❌ Specific  ❌ Measurable  ✅ Independent
     Score: 2/4
     Suggestion: "Invalid password shows 'Incorrect password' error"

  4. "Password reset works"
     ✅ Testable  ✅ Specific  ✅ Measurable  ✅ Independent
     Score: 4/4 ✓

OVERALL: 10/16 (62%) 🟡 NEEDS WORK

Fix 2 acceptance criteria before autonomous execution?
```

## STEP 6: Offer to Fix (Optional)

If score < 100% and user wants to fix:

Use AskUserQuestion to clarify each vague criterion:
- Present the vague criterion
- Show the suggested improvement
- Ask: "Should I update to: '[suggestion]'?"

If user approves, update the acceptance criteria in `agentc.json`.

## Key Principles

- **Be strict** - Vague goals waste autonomous execution time
- **Be helpful** - Always suggest concrete improvements
- **Be honest** - Don't let sloppy criteria through
- **Goal: 100% autonomy** - High-quality criteria enable this
