---
name: product-discovery
description: Use when starting a new product area or major feature from scratch. Guides the full discovery flow from Jobs-to-be-Done through to implementation-ready vertical slices.
---

# Product Discovery

## Overview

Complete discovery flow from raw idea to implementation-ready slices.

**Announce at start:** "I'm using the product-discovery skill to guide you from idea to implementation-ready slices."

This master skill chains together the full discovery process with checkpoints between each phase. You can stop at any phase and resume later.

## The Flow

    Phase 1: JTBD Discovery
         ↓
    Phase 2: Story Mapping
         ↓
    Phase 3: Feature Writing
         ↓
    Phase 4: Vertical Slicing
         ↓
    Phase 5: Implementation

Each phase has a checkpoint where you can pause, review, and decide whether to continue.

## Phase 1: JTBD Discovery

**Skill:** superpowers:jtbd-discovery

**Purpose:** Unearth the jobs users are trying to accomplish

**Process:**
- Understand project context
- Ask Socratic questions one at a time
- Discover functional, emotional, social jobs
- Validate each job before continuing

**Output:** docs/jtbd/YYYY-MM-DD-domain.md

**Checkpoint:** "Jobs discovered and documented. Ready to derive user stories?"

## Phase 2: Story Mapping

**Skill:** superpowers:story-mapping

**Purpose:** Convert jobs into INVEST-compliant user stories

**Process:**
- Read discovered jobs
- Derive stories one at a time
- Apply INVEST criteria
- Prioritize with MoSCoW

**Output:** docs/stories/YYYY-MM-DD-feature.md

**Checkpoint:** "Stories mapped and prioritized. Ready to write feature files?"

## Phase 3: Feature Writing

**Skill:** superpowers:feature-writing

**Purpose:** Write executable Gherkin feature files

**Process:**
- Read user stories
- Set up Cucumber if needed
- Write scenarios (tier-appropriate coverage)
- Create step definitions

**Output:** features/*.feature + step definitions

**Checkpoint:** "Feature files written. Ready to plan vertical slices?"

## Phase 4: Vertical Slicing

**Skill:** superpowers:vertical-slicing

**Purpose:** Plan thin vertical slices and create worktrees

**Process:**
- Read feature files
- Identify thinnest valuable slices
- Create worktree for each slice
- Create implementation plan for each

**Output:** Worktree + plan per slice

**Checkpoint:** "Slices planned and worktrees ready. Ready to start implementing?"

## Phase 5: Implementation

**Skill:** superpowers:executing-plans or superpowers:subagent-driven-development

**Purpose:** Implement slices with TDD discipline

**Process:**
- Move to first slice worktree
- Follow implementation plan
- TDD: test first, then code
- Merge when complete, move to next slice

**Output:** Working, tested code

## Resuming Mid-Flow

If you stopped at any phase, you can resume:

- **After Phase 1:** /story-mapping (reads from docs/jtbd/)
- **After Phase 2:** /feature-writing (reads from docs/stories/)
- **After Phase 3:** /vertical-slicing (reads from features/)
- **After Phase 4:** cd into worktree, continue with plan

## Key Principles

- **Checkpoint at each phase** - Never auto-continue without approval
- **Artifacts persist** - Each phase writes documents that can be resumed
- **One question at a time** - Applies throughout all phases
- **YAGNI throughout** - Remove unnecessary jobs, stories, features, slices
- **Validation before continuation** - Confirm each artifact before moving on

## When to Use

**Use product-discovery when:**
- Starting a new product area
- Major new feature with unclear scope
- Exploring a problem space before solutioning
- You want the full guided experience

**Use individual skills when:**
- You already have jobs and need stories
- You already have stories and need features
- You want to skip phases you've already done

## Integration

**Chains through:**
1. superpowers:jtbd-discovery
2. superpowers:story-mapping
3. superpowers:feature-writing
4. superpowers:vertical-slicing
5. superpowers:executing-plans / superpowers:subagent-driven-development
6. superpowers:finishing-a-development-branch
