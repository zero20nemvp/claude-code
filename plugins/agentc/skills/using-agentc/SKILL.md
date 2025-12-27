---
name: using-agentc
description: Use when starting any conversation - establishes the AgentC workflow (next→do→done) and mandatory skill usage for TDD, debugging, brainstorming, and verification
---

<EXTREMELY-IMPORTANT>
AgentC = Superpowers methodology + Cognitive-load-reducing interface

If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST read the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

# The AgentC Workflow

## Core Commands

```
/add-goal    → Brainstorming to capture design
/add-intent  → Write-plan to create bite-sized tasks
/next        → Get ONE optimal task (AI dispatched in parallel)
/do          → Execute with TDD discipline + automatic code review
/done        → Record with verification evidence
```

## The Discipline

**For every code task:**
1. **TDD**: Write test → See RED → Implement → See GREEN → Refactor
2. **Code Review**: Automatic after /do completes
3. **Verification**: Must see actual test output before /done

## MANDATORY FIRST RESPONSE PROTOCOL

Before responding to ANY user message:

1. ☐ Check: Is there an active task? → `/now`
2. ☐ Check: Does a skill apply to this request?
3. ☐ If skill applies → Use the Skill tool to read it
4. ☐ Announce which skill you're using
5. ☐ Follow the skill exactly

**Responding WITHOUT completing this checklist = automatic failure.**

## Skills Available

All embedded skills (use via Skill tool when needed):

**Core Discipline:**
- `test-driven-development` - RED-GREEN-REFACTOR (mandatory for code)
- `systematic-debugging` - 4-phase root cause investigation
- `verification-before-completion` - Evidence before claims

**Design & Planning:**
- `brainstorming` - Socratic design refinement
- `writing-plans` - Bite-sized implementation tasks
- `executing-plans` - Batch execution with checkpoints

**Quality:**
- `requesting-code-review` - Dispatch code reviewer
- `testing-anti-patterns` - Common testing mistakes
- `defense-in-depth` - Multiple validation layers

**Collaboration:**
- `dispatching-parallel-agents` - Concurrent subagent workflows
- `subagent-driven-development` - Per-task subagents

## Common Rationalizations That Mean You're About To Fail

If you catch yourself thinking ANY of these:

- "This is just a simple question" → WRONG. Check for skills.
- "Let me gather information first" → WRONG. Skills tell you HOW.
- "This doesn't need TDD" → WRONG. Code tasks require TDD.
- "I'll skip code review this time" → WRONG. Review is automatic.
- "The skill is overkill" → WRONG. Skills exist because simple things become complex.

## Skills with Checklists

If a skill has a checklist, YOU MUST create TodoWrite todos for EACH item.

**Why:** Checklists without TodoWrite tracking = steps get skipped.

## Summary

**The only interface:**
```
/next → /do → /done (repeat)
```

**The discipline is enforced:**
- TDD for code tasks
- Automatic code review
- Verification before completion
- One task at a time

**Skills are mandatory:**
- If a skill applies, use it
- Announce usage
- Follow exactly
