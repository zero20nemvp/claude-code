---
name: story-mapping
description: Use after JTBD discovery or when you have jobs/needs to convert into user stories. Transforms jobs into INVEST-compliant user stories with acceptance criteria.
---

# Story Mapping

## Overview

Convert Jobs-to-be-Done into well-formed user stories through collaborative refinement.

**Announce at start:** "I'm using the story-mapping skill to derive user stories from the discovered jobs."

Read jobs from the JTBD document (or discover inline), then derive stories one at a time. Apply INVEST criteria and present each story for validation before continuing.

## The Process

**Loading context:**
- Read the JTBD document if available (docs/jtbd/*.md)
- Identify target user roles/personas
- Understand the job hierarchy (primary, secondary, related)

**Deriving stories (one at a time):**
- Take each job and ask: "What capabilities does the user need?"
- Break capability into smallest valuable increment
- Present story for validation before moving on
- Ask: "Does this story capture the right scope?"

**INVEST validation for each story:**
- **I**ndependent - Can be developed in any order
- **N**egotiable - Details can be discussed
- **V**aluable - Delivers user value
- **E**stimable - Can be sized (S/M/L)
- **S**mall - Fits in one vertical slice
- **T**estable - Has clear pass/fail criteria

**Story size guidance:**
- **S (Small):** 1-2 scenarios, single worktree
- **M (Medium):** 3-4 scenarios, single worktree
- **L (Large):** 5+ scenarios, consider splitting

## Story Format

**As a** [role]
**I want** [capability]
**So that** [benefit tied to original job]

### Acceptance Criteria

Write in Given/When/Then format:

**Given** [precondition]
**When** [action]
**Then** [expected outcome]

Example:

    As a code reviewer
    I want to see a diff summary at the top of the PR
    So that I can quickly understand what changed without scrolling

    Acceptance Criteria:
    - Given a PR with 5 changed files
      When I view the PR page
      Then I see a summary showing files changed, insertions, deletions

    - Given a PR with only documentation changes
      When I view the PR page
      Then I see a "docs only" indicator in the summary

## Prioritization

After deriving stories, prioritize using MoSCoW:

**Must have:** Required for the job to be done
**Should have:** Important but workarounds exist
**Could have:** Nice to have if time permits
**Won't have:** Explicitly out of scope (for now)

## Output

Write validated stories to: docs/stories/YYYY-MM-DD-feature.md

Document format:
- Feature area name
- Source JTBD document reference
- Stories grouped by priority (Must/Should/Could)
- Each story with: role, capability, benefit, acceptance criteria, size (S/M/L)

## After Mapping

**If continuing to features:**
- Ask: "Ready to write Gherkin feature files from these stories?"
- Use superpowers:feature-writing to generate .feature files

**If stopping here:**
- Commit the stories document to git
- Stories can be picked up later with /feature-writing

## Key Principles

- **One story at a time** - Validate before moving on
- **INVEST strictly** - If it doesn't pass, refine it
- **Size matters** - L stories should probably split
- **Acceptance criteria are concrete** - Given/When/Then, not vague descriptions
- **Trace to jobs** - Every story should trace back to a job
- **YAGNI ruthlessly** - If it's not needed for the job, it's not a story

## Integration

**Called by:**
- superpowers:jtbd-discovery (after job discovery)
- superpowers:product-discovery (Phase 2)

**Chains to:**
- superpowers:feature-writing (write Gherkin scenarios)
