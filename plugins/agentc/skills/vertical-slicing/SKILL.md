---
name: vertical-slicing
description: Use after feature writing or when you have feature files ready for implementation. Plans thin vertical slices touching all layers and creates worktrees for each slice.
---

# Vertical Slicing

## Overview

Plan thin vertical slices from feature files and create isolated worktrees for implementation.

**Announce at start:** "I'm using the vertical-slicing skill to plan vertical slices and create worktrees."

Read feature files, identify the thinnest possible slices that touch all layers, then create a worktree and implementation plan for each slice.

## The Process

**Loading context:**
- Read feature files from features/*.feature
- Identify scenarios and their dependencies
- Review existing models, controllers, views for integration points

**Identifying slices:**
- Each slice should touch: Model → Controller → View → Test
- Default: 1 user story = 1 vertical slice
- Split L-size stories into multiple slices if needed
- Each slice should be independently deployable

**Slice anatomy for Rails:**

    Slice: "User can register with email"

    Layers touched:
    - Model: User (email, password_digest)
    - Controller: RegistrationsController#create
    - View: registrations/new.html.erb
    - Routes: resources :registrations, only: [:new, :create]
    - Feature: features/user_registration.feature (1-2 scenarios)
    - Specs: spec/models/user_spec.rb, spec/requests/registrations_spec.rb

**Presenting slices:**
- Present each slice with layers it touches
- Ask: "Does this slice look right? Too big? Too small?"
- Refine based on feedback before creating worktree

## Worktree Creation

For each approved slice:

1. **Create worktree** via superpowers:using-git-worktrees
   - Branch name: feature/[slice-name]
   - Directory: worktrees/[slice-name] or as configured

2. **Create implementation plan** via superpowers:writing-plans
   - Bite-sized tasks (2-5 min each)
   - TDD: test first, then implementation
   - Cover all layers in the slice

3. **Offer to begin:**
   - Ask: "Ready to start implementing this slice?"
   - If yes, chain to execution skill
   - If no, move to next slice

## Slice Sizing

**Good slice (do this):**
- Single scenario or tightly related scenarios
- One model change + one controller action + one view
- Can be completed and merged in one session
- Provides user-visible value

**Too big (split it):**
- Multiple unrelated scenarios
- Changes to 3+ models
- Multiple controller actions with different purposes
- Would take multiple sessions

**Too small (combine it):**
- Only touches one layer
- No user-visible value on its own
- Database migration with no consuming code

## Output

For each slice:
- Worktree at configured location
- Implementation plan at docs/plans/YYYY-MM-DD-[slice-name].md
- Branch: feature/[slice-name]

## Slice Ordering

Present slices in dependency order:
1. Foundation slices first (models, core logic)
2. Feature slices next (controllers, views)
3. Polish slices last (edge cases, refinements)

Ask: "Which slice would you like to start with?"

## After Slicing

**If continuing to implementation:**
- Move to first worktree
- Use superpowers:executing-plans or superpowers:subagent-driven-development
- Follow TDD discipline

**If stopping here:**
- Worktrees are ready for later
- Plans are committed
- Can resume with: cd [worktree-path] and continue

## Key Principles

- **Thin slices** - Touch all layers but minimally
- **Independent** - Each slice can be merged alone
- **Valuable** - Each slice delivers user value
- **TDD ready** - Plan includes test-first steps
- **One at a time** - Complete one slice before starting next
- **Vertical, not horizontal** - Never "do all models first"

## Integration

**Called by:**
- superpowers:feature-writing (after features written)
- superpowers:product-discovery (Phase 4)

**Chains to:**
- superpowers:using-git-worktrees (create isolated workspace)
- superpowers:writing-plans (create implementation plan)
- superpowers:executing-plans (implement the slice)
- superpowers:finishing-a-development-branch (merge completed slice)
