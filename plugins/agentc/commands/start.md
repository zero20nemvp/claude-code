---
name: start
description: "Start autonomous execution - Claude drives, human executes assigned tasks"
arguments:
  - name: goal
    description: "North Star ID, Goal ID, or goal description to focus on"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion

Implementation details are in CLAUDE.md - see "Command Implementations" section.
