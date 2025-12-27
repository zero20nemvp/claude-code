---
description: "Create a skill or MCP to automate recurring human tasks - path to 100% automation"
arguments:
  - name: pattern-id
    description: "Index of skill opportunity to automate (from /skill list)"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
  - AskUserQuestion
---

You are creating skills to eliminate recurring human tasks. The goal is 100% autonomous execution - every skill created reduces human work.

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

## STEP 1: Load Skill Opportunities

Load `agentc/agentc.json` and extract `metrics.skillOpportunities[]`.

## STEP 2: Display Opportunities (if no pattern-id)

If no pattern-id argument provided, show the list:

```
═══════════════════════════════════════════════════════════════
                    SKILL OPPORTUNITIES
═══════════════════════════════════════════════════════════════

Path to 100% automation: Create skills to eliminate human tasks

TOP OPPORTUNITIES:

  1. 🔥 "SSH to production server"
     Occurrences: 12 | Impact: HIGH
     Capability gap: external_system_access
     Suggested: MCP server with SSH tunneling

  2. "Test on iOS device"
     Occurrences: 8 | Impact: MEDIUM
     Capability gap: physical_device_testing
     Suggested: iOS Simulator integration

  3. "Review email copy"
     Occurrences: 3 | Impact: LOW
     Capability gap: subjective_ux_judgment
     Suggested: Email template checklist

═══════════════════════════════════════════════════════════════

AUTOMATION PROGRESS:
  Current: 94% autonomous
  Target: 100%
  If #1 automated: → 97% autonomous

Run /skill [number] to create automation
```

**Wait for user to select a pattern.**

## STEP 3: Analyze Selected Pattern

If pattern-id provided, load the specific opportunity:

```json
{
  "pattern": "SSH to production server",
  "occurrences": 12,
  "capabilityGap": "external_system_access",
  "examples": [
    "ssh user@prod ./deploy.sh",
    "ssh user@prod ./restart-service.sh",
    "ssh user@prod ./check-logs.sh"
  ]
}
```

## STEP 4: Determine Automation Strategy

Based on capability gap, determine best approach:

| Capability Gap | Strategy | Implementation |
|----------------|----------|----------------|
| `external_system_access` | MCP Server | Create MCP spec for SSH/API access |
| `physical_device_testing` | Simulator | iOS/Android simulator integration |
| `real_browser_session` | Puppeteer MCP | Browser automation server |
| `strategic_authority` | Decision Tree | Pre-approved decision skill |
| `external_communication` | API Integration | Slack/Email MCP |
| `subjective_ux_judgment` | Checklist | Design system verification skill |
| `domain_expertise` | Knowledge Skill | Document expertise as skill |

## STEP 5: Ask Clarifying Questions

Use AskUserQuestion to understand the pattern better:

```
Analyzing: "SSH to production server"

Questions:

1. What authentication method is used?
   - SSH key
   - Password
   - SSO/Certificate

2. What commands are typically run?
   - Deployments
   - Log checking
   - Service restarts
   - Database operations

3. Are there any approval requirements?
   - No approval needed
   - Requires manager approval
   - Requires change ticket
```

## STEP 6: Generate Skill/MCP

### For MCP Server:

Create specification document:

```markdown
# [Pattern Name] MCP Server

## Purpose
Automates: [pattern description]
Eliminates: ~[N] human tasks per month

## Authentication
[Based on answers]

## Available Tools

### tool_name
Description: [what it does]
Parameters:
  - param1: [description]
  - param2: [description]
Returns: [what it returns]

## Security Considerations
- [security notes]

## Installation
[installation steps]
```

Save to: `plugins/agentc/mcp-specs/[name].md`

### For Skill:

Create skill document following existing pattern:

```markdown
---
name: [skill-name]
description: [description]
---

# [Skill Name]

[Procedural instructions that codify the pattern]
```

Save to: `plugins/agentc/skills/[name]/SKILL.md`

### For Checklist:

Create verification checklist:

```markdown
---
name: [checklist-name]
description: [description]
---

# [Checklist Name]

## Verification Steps

- [ ] [Check 1]
- [ ] [Check 2]
- [ ] [Check 3]

## Pass Criteria
[What constitutes passing]
```

## STEP 7: Update State

Update `agentc/agentc.json`:

1. Add to `metrics.skillsCreated[]`:
```json
{
  "name": "[skill name]",
  "type": "mcp|skill|checklist",
  "eliminates": "[pattern]",
  "createdAt": "[ISO timestamp]",
  "estimatedImpact": "[X] tasks/month"
}
```

2. Remove from `metrics.skillOpportunities[]` (or mark as addressed)

3. Update `metrics.automationProgress.currentRatio` projection

## STEP 8: Output Summary

```
═══════════════════════════════════════════════════════════════
                    SKILL CREATED
═══════════════════════════════════════════════════════════════

Name: [skill name]
Type: [MCP Server | Skill | Checklist]
Location: [file path]

ELIMINATES:
  Pattern: "[pattern description]"
  Occurrences: ~[N] per month

IMPACT:
  Before: 94% autonomous
  After: 97% autonomous (+3%)

NEXT STEPS:
  [For MCP]: Install the MCP server to enable this automation
  [For Skill]: Skill is now active and will be used automatically
  [For Checklist]: Checklist will be applied to relevant tasks

═══════════════════════════════════════════════════════════════
```

## Key Principles

- **Goal is 100%** - Every skill moves toward zero human intervention
- **Measure impact** - Track how much each skill reduces human work
- **Be practical** - Create what can actually be implemented
- **Continuous improvement** - Keep identifying and eliminating patterns
