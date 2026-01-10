---
name: skill
description: "Create a new skill from recurring patterns - transforms repeated manual tasks into reusable automations"
arguments:
  - name: index
    description: "Index of skill opportunity to automate (from /skill list)"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
---

You are creating a new skill from recurring patterns. Skills codify knowledge to reduce human load.

## Directory Detection

Use `agentc/` as `$DIR`. Load `$DIR/agentc.json`.

## Mode Detection

**If no argument provided:** Show skill opportunities list
**If index provided:** Create skill from that pattern

## List Mode (no argument)

Analyze `patterns.manualTasks` in agentc.json and suggest skill opportunities:

```
=== SKILL OPPORTUNITIES ===

Recurring patterns detected:

1. "SSH to production" (12 occurrences)
   → Could automate with: MCP server for SSH

2. "Review email copy" (8 occurrences)
   → Could automate with: Skill for copywriting patterns

3. "Check deployment status" (6 occurrences)
   → Could automate with: Script + health endpoint

Run: /skill 1  to create skill from pattern #1
```

If no patterns found:
```
No recurring patterns detected yet.

Patterns are tracked when human tasks repeat across sessions.
Keep using /next → /do → /done and check back later.
```

## Create Mode (with index)

1. **Load pattern** from `patterns.manualTasks[index-1]`

2. **Analyze pattern:**
   - What capability gap does this represent?
   - Can it be automated with an MCP server?
   - Can it be codified as a skill document?
   - What information is needed to automate?

3. **Create skill using TDD approach:**
   - Follow `superpowers:writing-skills` methodology
   - Test with subagent before finalizing
   - Document in `skills/[skill-name]/SKILL.md`

4. **Output:**
```
=== SKILL CREATED ===

Name: [skill-name]
Type: [MCP | Skill | Script]
Location: skills/[skill-name]/SKILL.md

This automates: "[pattern description]"

Next steps:
1. Test the skill in a real scenario
2. Refine based on usage
3. Consider contributing back via PR

Pattern removed from tracking.
```

## Capability Gap Types

| Gap Type | Solution |
|----------|----------|
| External system access | MCP server |
| Domain knowledge | Skill document |
| Repetitive process | Script/automation |
| Subjective judgment | Checklist + examples |

## Update State

After creating skill:
1. Remove pattern from `patterns.manualTasks`
2. Log to `journal` with skill creation details
3. Update `suggestedCapabilities` if MCP suggested

## Output

Always end with:
```
DO: /next
```
