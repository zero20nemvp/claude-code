---
name: add-goal
description: "Add a new goal (WOOP commitment) with milestones toward a North Star"
arguments:
  - name: north-star-id
    description: "The North Star ID to add a goal for (e.g., ns1)"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion

Implementation details are in CLAUDE.md - see "Command Implementations" section.
