---
name: verification-before-completion
description: Use when about to claim work is complete - requires running verification commands and confirming output before making any success claims
---

# Verification Before Completion

## Overview

Evidence before claims, always.

## The Gate Function

```
BEFORE claiming completion:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the command (fresh, complete)
3. READ: Check output and exit code
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
```

## Common Claims and Evidence

| Claim | Evidence Required |
|-------|-------------------|
| Tests pass | Test command output showing 0 failures |
| Build succeeds | Build command with exit 0 |
| Bug fixed | Test reproducing bug now passes |
| Linter clean | Linter output: 0 errors |
| Requirements met | Each requirement verified individually |

## Key Patterns

**Tests:**
```
[Run test command] → [See: 34/34 pass] → "All tests pass"
```

**Build:**
```
[Run build] → [See: exit 0] → "Build passes"
```

**Bug fix (TDD Red-Green):**
```
Write test → Run (FAIL) → Fix → Run (PASS) → "Bug fixed"
```

**Requirements:**
```
Re-read plan → Create checklist → Verify each → Report gaps or completion
```

## When To Apply

Before:
- Claiming work is complete
- Committing or creating PRs
- Moving to next task
- Reporting status

## The Rule

**Run the command. Read the output. THEN claim the result.**
