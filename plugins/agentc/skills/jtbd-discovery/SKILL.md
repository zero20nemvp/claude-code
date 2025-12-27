---
name: jtbd-discovery
description: Use when starting a new feature or product area to unearth Jobs-to-be-Done through Socratic dialogue. Discovers what users are really trying to accomplish before jumping to solutions.
---

# Jobs-to-be-Done Discovery

## Overview

Unearth the jobs users are hiring your product to do through natural Socratic dialogue.

**Announce at start:** "I'm using the jtbd-discovery skill to unearth the jobs your users need to accomplish."

Start by understanding the current project context, then ask questions one at a time to discover jobs. Focus on situations, motivations, and desired outcomes - not features or solutions.

## The Process

**Understanding context:**
- Check out the current project state first (files, docs, recent commits)
- Identify existing user personas or segments if available
- Review any existing research, feedback, or support tickets

**Discovering jobs (one question at a time):**
- "When does this problem occur? What triggers it?"
- "What is the user trying to accomplish in that moment?"
- "What does success look like for them?"
- "What are they currently doing to solve this?"
- "What's frustrating about their current approach?"

**Job dimensions to explore:**
- **Functional:** What task are they trying to complete?
- **Emotional:** How do they want to feel?
- **Social:** How do they want to be perceived?

**Validating jobs incrementally:**
- Present each discovered job for confirmation
- Ask: "Does this capture the core job?"
- Refine based on feedback before moving to next job

## Job Statement Format

Structure each job as:

**When** [situation/trigger]
**I want to** [motivation/action]
**So I can** [expected outcome]

Example:
- When I'm reviewing pull requests at the end of the day
- I want to quickly understand what changed and why
- So I can provide useful feedback without spending hours on context

## Prioritization

After discovering jobs, prioritize them:

**Primary jobs:** Core reasons users hire the product
**Secondary jobs:** Important but not the main driver
**Related jobs:** Adjacent needs that emerge during the primary job

## Output

Write validated jobs to: docs/jtbd/YYYY-MM-DD-domain.md

Document format:
- Domain/area name
- Target user segment
- Primary jobs (1-3)
- Secondary jobs (0-3)
- Related jobs (0-3)
- Success criteria for each job

## After Discovery

**If continuing to stories:**
- Ask: "Ready to turn these jobs into user stories?"
- Use superpowers:story-mapping to derive stories from jobs

**If stopping here:**
- Commit the JTBD document to git
- Jobs can be picked up later with /story-mapping

## Key Principles

- **One question at a time** - Deep discovery, not rapid-fire
- **Jobs, not solutions** - Focus on what users need to accomplish, not how
- **Situation matters** - The "when" is as important as the "what"
- **Emotional jobs count** - Users have feelings, not just tasks
- **Validate incrementally** - Confirm each job before moving on
- **YAGNI applies** - Don't invent jobs that don't exist

## Integration

**Called by:**
- superpowers:product-discovery (Phase 1)

**Chains to:**
- superpowers:story-mapping (derive user stories from jobs)
